//
//  CameraClientImpl.swift
//  Data
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import Dependencies
import Domain
import os
import UIKit

// MARK: - DependencyKey

extension CameraClient: @retroactive DependencyKey {
    public static let liveValue: CameraClient = CameraClientImpl.live()
}

// MARK: - CameraClientImpl

private final class CameraClientImpl: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.orange.peaktime.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private struct MutableState {
        var currentPosition: AVCaptureDevice.Position = .back
        var flashMode: AVCaptureDevice.FlashMode = .off
        var photoContinuation: CheckedContinuation<CapturedPhoto, Error>?
        var wasRunningBeforeBackground = false
    }

    private let state = OSAllocatedUnfairLock(initialState: MutableState())
    private var lensSwitchObservation: NSKeyValueObservation?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?

    static func live() -> CameraClient {
        let manager = CameraClientImpl()
        manager.setupAppLifecycleObservers()

        return CameraClient(
            startSession: {
                try manager.configureSession()
                manager.startRunning()
            },
            stopSession: {
                manager.stopAndReset()
            },
            capturePhoto: {
                try await manager.capturePhoto()
            },
            switchCamera: {
                try manager.switchCamera()
            },
            setZoomFactor: { factor, animated in
                try manager.setZoomFactor(factor, animated: animated)
            },
            setFlashMode: { isOn in
                manager.state.withLock { $0.flashMode = isOn ? .on : .off }
            },
            getSession: {
                manager.session
            }
        )
    }

    // MARK: - Session Configuration

    private func configureSession() throws {
        try sessionQueue.sync { [self] in
            try configureSessionOnQueue()
        }
    }

    private func configureSessionOnQueue() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        let position = state.withLock { $0.currentPosition }
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
            try? device.lockForConfiguration()
            device.videoZoomFactor = wideAngleFactor
            device.unlockForConfiguration()
        }

        configureLensSwitching(for: device)
    }

    private func configureLensSwitching(for device: AVCaptureDevice) {
        lensSwitchObservation?.invalidate()
        lensSwitchObservation = nil

        guard !device.virtualDeviceSwitchOverVideoZoomFactors.isEmpty else { return }

        try? device.lockForConfiguration()
        device.setPrimaryConstituentDeviceSwitchingBehavior(
            .restricted,
            restrictedSwitchingBehaviorConditions: .videoZoomChanged
        )
        device.unlockForConfiguration()

        lensSwitchObservation = device.observe(\.activePrimaryConstituent) { _, _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("CameraLensSwitched"), object: nil)
            }
        }
    }

    private func startRunning() {
        sessionQueue.async { [self] in
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }

    private func stopAndReset() {
        sessionQueue.sync { [self] in
            state.withLock {
                $0.currentPosition = .back
                $0.flashMode = .off
            }

            guard session.isRunning else { return }
            lensSwitchObservation?.invalidate()
            lensSwitchObservation = nil
            session.stopRunning()

            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            session.commitConfiguration()
        }
    }

    private func stopRunning() {
        sessionQueue.async { [self] in
            guard session.isRunning else { return }
            lensSwitchObservation?.invalidate()
            lensSwitchObservation = nil
            session.stopRunning()

            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            session.commitConfiguration()
        }
    }

    // MARK: - App Lifecycle

    private func setupAppLifecycleObservers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.session.isRunning else { return }
            self.state.withLock { $0.wasRunningBeforeBackground = true }
            self.stopRunning()
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let wasRunning = self.state.withLock {
                let value = $0.wasRunningBeforeBackground
                $0.wasRunningBeforeBackground = false
                return value
            }
            guard wasRunning else { return }
            self.sessionQueue.async { [self] in
                guard (try? self.configureSessionOnQueue()) != nil else { return }
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            }
        }
    }

    // MARK: - Capture

    private func capturePhoto() async throws -> CapturedPhoto {
        try await withCheckedThrowingContinuation { continuation in
            let flashMode = self.state.withLock { s -> AVCaptureDevice.FlashMode? in
                guard s.photoContinuation == nil else { return nil }
                s.photoContinuation = continuation
                return s.flashMode
            }

            guard let flashMode else {
                continuation.resume(throwing: CameraError.captureAlreadyInProgress)
                return
            }

            let settings = AVCapturePhotoSettings()
            if photoOutput.supportedFlashModes.contains(flashMode) {
                settings.flashMode = flashMode
            }

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - Switch Camera

    private func switchCamera() throws {
        try sessionQueue.sync { [self] in
            state.withLock {
                $0.currentPosition = ($0.currentPosition == .back) ? .front : .back
            }
            try configureSessionOnQueue()
        }
    }

    // MARK: - Zoom

    private func setZoomFactor(_ factor: CGFloat, animated: Bool) throws {
        try sessionQueue.sync {
            guard let device = currentDevice() else {
                throw CameraError.deviceNotAvailable
            }

            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            let wideAngleBase = device.virtualDeviceSwitchOverVideoZoomFactors.first?.doubleValue ?? 1.0
            let deviceFactor = factor * wideAngleBase
            let clamped = min(max(deviceFactor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)

            if animated {
                device.ramp(toVideoZoomFactor: clamped, withRate: 3.0)
            } else {
                device.videoZoomFactor = clamped
            }
        }
    }

    // MARK: - Helpers

    private func cameraDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
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

    private func currentDevice() -> AVCaptureDevice? {
        (session.inputs.first as? AVCaptureDeviceInput)?.device
    }

    private func cropToSquare(_ image: UIImage) -> UIImage {
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

extension CameraClientImpl: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let continuation = state.withLock { s -> CheckedContinuation<CapturedPhoto, Error>? in
            let c = s.photoContinuation
            s.photoContinuation = nil
            return c
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

        let position = state.withLock { $0.currentPosition }
        let device = currentDevice()
        let capturedPhoto = CapturedPhoto(
            imageData: squareData,
            capturedAt: Date(),
            cameraPosition: position == .front ? .front : .back,
            zoomLevel: device?.videoZoomFactor ?? 1.0
        )

        continuation.resume(returning: capturedPhoto)
    }
}

// MARK: - CameraError

private enum CameraError: Error {
    case deviceNotAvailable
    case cannotAddInput
    case cannotAddOutput
    case captureDataMissing
    case captureAlreadyInProgress
}
