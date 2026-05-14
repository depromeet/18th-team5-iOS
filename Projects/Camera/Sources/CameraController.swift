//
//  CameraController.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import Core
import Observation
import os
import UIKit

@Observable
public final class CameraController: NSObject, @unchecked Sendable {
    // MARK: - 외부 관찰 가능한 상태

    public private(set) var isFlashOn: Bool = false
    public private(set) var currentZoomFactor: CGFloat = 1.0
    public private(set) var isFrontCamera: Bool = false
    public private(set) var isSessionRunning: Bool = false
    public private(set) var errorMessage: String?
    public private(set) var baseZoomFactor: CGFloat = 1.0

    // MARK: - 줌 범위

    public var minZoomFactor: CGFloat {
        isFrontCamera ? 1.0 : 0.5
    }

    public var maxZoomFactor: CGFloat {
        isFrontCamera ? 5.0 : 10.0
    }

    // MARK: - Internal

    private let logger = Logger(handlers: [DebugLogHandler()])
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.orange.peaktime.camera.session")
    private let photoOutput = AVCapturePhotoOutput()

    private struct MutableState {
        enum SessionPhase {
            case idle
            case configuring
            case running
            case stopping
        }

        var sessionPhase: SessionPhase = .idle
        var currentPosition: AVCaptureDevice.Position = .back
        var flashMode: AVCaptureDevice.FlashMode = .off
        var photoContinuation: CheckedContinuation<CapturedResult, Error>?
        var wasRunningBeforeBackground = false
    }

    private let mutableState = OSAllocatedUnfairLock(initialState: MutableState())
    private var lensSwitchObservation: NSKeyValueObservation?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?

    // MARK: - Init

    override public init() {
        super.init()
        setupAppLifecycleObservers()
    }

    deinit {
        if let backgroundObserver { NotificationCenter.default.removeObserver(backgroundObserver) }
        if let foregroundObserver { NotificationCenter.default.removeObserver(foregroundObserver) }
        lensSwitchObservation?.invalidate()
    }

    // MARK: - Public 메서드

    public func clearError() {
        errorMessage = nil
    }

    public func startSession() async throws {
        do {
            try configureSession()
            startRunning()
            let zoom = currentZoomFactor
            try setZoomOnDevice(zoom, animated: false)
        } catch {
            logger.error(message: "카메라 세션 시작 실패: \(error)")
            errorMessage = "카메라를 시작할 수 없습니다."
            throw error
        }
    }

    public func stopSession() async {
        stopAndReset()
    }

    public func capturePhoto() async throws -> CapturedResult {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let flashMode = self.mutableState.withLock { state -> AVCaptureDevice.FlashMode? in
                    guard state.photoContinuation == nil else { return nil }
                    state.photoContinuation = continuation
                    return state.flashMode
                }

                guard let flashMode else {
                    continuation.resume(throwing: CameraError.captureAlreadyInProgress)
                    return
                }

                let settings = AVCapturePhotoSettings()
                if self.photoOutput.supportedFlashModes.contains(flashMode) {
                    settings.flashMode = flashMode
                }

                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        } catch {
            logger.error(message: "사진 촬영 실패: \(error)")
            errorMessage = "사진 촬영에 실패했습니다."
            throw error
        }
    }

    public func toggleFlash() {
        isFlashOn.toggle()
        mutableState.withLock { $0.flashMode = isFlashOn ? .on : .off }
    }

    public func switchCamera() async throws {
        do {
            try switchCameraOnQueue()
            isFrontCamera.toggle()
            let initialZoom: CGFloat = isFrontCamera ? Self.selfieCloseUpZoom : 1.0
            currentZoomFactor = initialZoom
            baseZoomFactor = initialZoom
            try setZoomOnDevice(initialZoom, animated: false)
        } catch {
            logger.error(message: "카메라 전환 실패: \(error)")
            errorMessage = "카메라 전환에 실패했습니다."
            throw error
        }
    }

    public func setZoom(_ factor: CGFloat, animated: Bool) throws {
        let clamped = min(max(factor, minZoomFactor), maxZoomFactor)
        currentZoomFactor = clamped
        baseZoomFactor = clamped
        try setZoomOnDevice(clamped, animated: animated)
    }

    public func setZoomFromPinch(_ magnification: CGFloat) throws {
        guard !isFrontCamera else { return }
        let newFactor = baseZoomFactor * magnification
        let clamped = min(max(newFactor, minZoomFactor), maxZoomFactor)
        guard clamped != currentZoomFactor else { return }
        currentZoomFactor = clamped
        try setZoomOnDevice(clamped, animated: false)
    }

    public func endPinchZoom() {
        guard !isFrontCamera else { return }
        baseZoomFactor = currentZoomFactor
    }

    public func toggleSelfieZoom() {
        let newFactor: CGFloat = currentZoomFactor <= 1.0 ? Self.selfieCloseUpZoom : 1.0
        currentZoomFactor = newFactor
        baseZoomFactor = newFactor
        do {
            try setZoomOnDevice(newFactor, animated: true)
        } catch {
            logger.warning(message: "셀피 줌 전환 실패: \(error)")
        }
    }

    // MARK: - Session Access (프리뷰용)

    public var captureSession: AVCaptureSession {
        session
    }
}

// MARK: - Private

private extension CameraController {
    static let selfieCloseUpZoom: CGFloat = 1.3

    func configureSession() throws {
        try sessionQueue.sync { [self] in
            try configureSessionGuarded()
        }
    }

    @discardableResult
    func configureSessionGuarded() throws -> Bool {
        let shouldProceed = mutableState.withLock { state -> Bool in
            switch state.sessionPhase {
            case .idle, .running:
                state.sessionPhase = .configuring
                return true
            case .configuring, .stopping:
                return false
            }
        }

        guard shouldProceed else {
            logger.warning(message: "세션 구성 건너뜀: 이미 진행 중인 작업 있음")
            return false
        }

        do {
            try configureSessionOnQueue()
            mutableState.withLock { $0.sessionPhase = .running }
            return true
        } catch {
            mutableState.withLock { $0.sessionPhase = .idle }
            throw error
        }
    }

    func configureSessionOnQueue() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        let position = mutableState.withLock { $0.currentPosition }
        guard let device = cameraDevice(for: position),
              let input = try? AVCaptureDeviceInput(device: device) else {
            throw CameraError.deviceNotAvailable
        }

        guard session.canAddInput(input) else {
            throw CameraError.cannotAddInput
        }
        session.addInput(input)

        guard session.canAddOutput(photoOutput) else {
            throw CameraError.cannotAddOutput
        }
        session.addOutput(photoOutput)

        if let wideAngleFactor = device.virtualDeviceSwitchOverVideoZoomFactors.first?.doubleValue {
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = wideAngleFactor
                device.unlockForConfiguration()
            } catch {
                assertionFailure("Failed to set wide angle zoom: \(error)")
            }
        }

        configureLensSwitching(for: device)
    }

    func configureLensSwitching(for device: AVCaptureDevice) {
        lensSwitchObservation?.invalidate()
        lensSwitchObservation = nil

        guard !device.virtualDeviceSwitchOverVideoZoomFactors.isEmpty else { return }

        do {
            try device.lockForConfiguration()
            device.setPrimaryConstituentDeviceSwitchingBehavior(
                .restricted,
                restrictedSwitchingBehaviorConditions: .videoZoomChanged
            )
            device.unlockForConfiguration()
        } catch {
            assertionFailure("Failed to configure lens switching: \(error)")
        }

        lensSwitchObservation = device.observe(\.activePrimaryConstituent) { _, _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .cameraLensSwitched, object: nil)
            }
        }
    }

    func startRunning() {
        sessionQueue.async { [self] in
            guard !session.isRunning else { return }
            session.startRunning()
            DispatchQueue.main.async { self.isSessionRunning = true }
        }
    }

    func stopAndReset() {
        sessionQueue.sync { [self] in
            let shouldStop = mutableState.withLock { state -> Bool in
                guard state.sessionPhase == .running else { return false }
                state.sessionPhase = .stopping
                state.currentPosition = .back
                state.flashMode = .off
                return true
            }

            guard shouldStop else { return }
            teardownSession()
            mutableState.withLock { $0.sessionPhase = .idle }
        }

        DispatchQueue.main.async { [self] in
            isFlashOn = false
            isFrontCamera = false
            currentZoomFactor = 1.0
            baseZoomFactor = 1.0
            isSessionRunning = false
        }
    }

    func stopRunning() {
        sessionQueue.async { [self] in
            let shouldStop = mutableState.withLock { state -> Bool in
                guard state.sessionPhase == .running else { return false }
                state.sessionPhase = .stopping
                return true
            }

            guard shouldStop else { return }
            teardownSession()
            mutableState.withLock { $0.sessionPhase = .idle }
        }
    }

    func teardownSession() {
        let pendingContinuation = mutableState.withLock { state -> CheckedContinuation<CapturedResult, Error>? in
            let result = state.photoContinuation
            state.photoContinuation = nil
            return result
        }
        pendingContinuation?.resume(throwing: CameraError.sessionStopped)

        lensSwitchObservation?.invalidate()
        lensSwitchObservation = nil
        session.stopRunning()
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()
    }

    // MARK: - App Lifecycle

    func setupAppLifecycleObservers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let isRunning = self.mutableState.withLock { $0.sessionPhase == .running }
            guard isRunning else { return }
            self.mutableState.withLock { $0.wasRunningBeforeBackground = true }
            self.stopRunning()
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let wasRunning = self.mutableState.withLock {
                let value = $0.wasRunningBeforeBackground
                $0.wasRunningBeforeBackground = false
                return value
            }
            guard wasRunning else { return }
            self.sessionQueue.async { [self] in
                do {
                    try self.configureSessionGuarded()
                    if !self.session.isRunning {
                        self.session.startRunning()
                    }
                    DispatchQueue.main.async {
                        self.isSessionRunning = true
                    }
                } catch {
                    self.logger.error(message: "포그라운드 복귀 시 세션 복구 실패: \(error)")
                    DispatchQueue.main.async {
                        self.isSessionRunning = false
                        self.errorMessage = "카메라를 다시 시작할 수 없습니다."
                    }
                }
            }
        }
    }

    // MARK: - Camera Switch

    func switchCameraOnQueue() throws {
        try sessionQueue.sync { [self] in
            mutableState.withLock {
                $0.currentPosition = ($0.currentPosition == .back) ? .front : .back
            }
            let configured = try configureSessionGuarded()
            if !configured {
                mutableState.withLock {
                    $0.currentPosition = ($0.currentPosition == .back) ? .front : .back
                }
                throw CameraError.sessionBusy
            }
        }
    }

    // MARK: - Zoom

    func setZoomOnDevice(_ factor: CGFloat, animated: Bool) throws {
        try sessionQueue.sync {
            guard let device = currentDevice() else {
                throw CameraError.deviceNotAvailable
            }

            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            let wideAngleBase = device.virtualDeviceSwitchOverVideoZoomFactors.first?.doubleValue ?? 1.0
            let deviceFactor = factor * wideAngleBase
            let clamped = min(
                max(deviceFactor, device.minAvailableVideoZoomFactor),
                device.maxAvailableVideoZoomFactor
            )

            if animated {
                device.ramp(toVideoZoomFactor: clamped, withRate: 3.0)
            } else {
                device.videoZoomFactor = clamped
            }
        }
    }

    // MARK: - Helpers

    func cameraDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if position == .back {
            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInWideAngleCamera],
                mediaType: .video,
                position: .back
            )
            return discovery.devices.first
        }
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }

    func currentDevice() -> AVCaptureDevice? {
        (session.inputs.first as? AVCaptureDeviceInput)?.device
    }

    func cropToSquare(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let size = min(cgImage.width, cgImage.height)
        let x = (cgImage.width - size) / 2
        let y = (cgImage.height - size) / 2
        let cropRect = CGRect(x: x, y: y, width: size, height: size)

        guard let cropped = cgImage.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let continuation = mutableState.withLock { state -> CheckedContinuation<CapturedResult, Error>? in
            let result = state.photoContinuation
            state.photoContinuation = nil
            return result
        }
        guard let continuation else { return }

        if let error {
            continuation.resume(throwing: error)
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            continuation.resume(throwing: CameraError.captureDataMissing)
            return
        }

        guard let originalImage = UIImage(data: data) else {
            continuation.resume(throwing: CameraError.captureDataMissing)
            return
        }

        let squareImage = cropToSquare(originalImage)
        guard let squareData = squareImage.jpegData(compressionQuality: 0.9) else {
            continuation.resume(throwing: CameraError.captureDataMissing)
            return
        }

        let position = mutableState.withLock { $0.currentPosition }
        let device = currentDevice()
        let capturedResult = CapturedResult(
            imageData: squareData,
            capturedAt: Date(),
            cameraPosition: position == .front ? .front : .back,
            zoomLevel: Double(device?.videoZoomFactor ?? 1.0)
        )

        continuation.resume(returning: capturedResult)
    }
}

// MARK: - Notification

extension Notification.Name {
    static let cameraLensSwitched = Notification.Name("CameraLensSwitched")
}

// MARK: - CameraError

public enum CameraError: Error {
    case deviceNotAvailable
    case cannotAddInput
    case cannotAddOutput
    case captureDataMissing
    case captureAlreadyInProgress
    case sessionStopped
    case sessionBusy
}
