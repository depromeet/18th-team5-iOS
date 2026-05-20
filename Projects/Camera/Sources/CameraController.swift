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
@MainActor
public final class CameraController: NSObject, @unchecked Sendable {
    // MARK: - 외부 관찰 가능한 상태

    public internal(set) var isFlashOn: Bool = false
    public internal(set) var currentZoomFactor: CGFloat = 1.0
    public internal(set) var isFrontCamera: Bool = false
    public internal(set) var isSessionRunning: Bool = false
    public internal(set) var errorMessage: String?
    public internal(set) var baseZoomFactor: CGFloat = 1.0

    // MARK: - 줌 범위

    public var minZoomFactor: CGFloat {
        isFrontCamera ? 1.0 : 0.5
    }

    public var maxZoomFactor: CGFloat {
        isFrontCamera ? 5.0 : 10.0
    }

    // MARK: - Internal

    nonisolated(unsafe) let photoOutput = AVCapturePhotoOutput()
    nonisolated(unsafe) let session = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "com.orange.peaktime.camera.session")
    let logger = Logger(handlers: [DebugLogHandler()])

    struct MutableState {
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

    let mutableState = OSAllocatedUnfairLock(initialState: MutableState())

    /// nonisolated 컨텍스트(sessionQueue, deinit)에서 접근하는 var 프로퍼티를
    /// @unchecked Sendable 컨테이너로 분리하여 cross-isolation 접근 허용
    final class ObserverState: @unchecked Sendable {
        var lensSwitchObservation: NSKeyValueObservation?
        var backgroundObserver: NSObjectProtocol?
        var foregroundObserver: NSObjectProtocol?
    }

    let observerState = ObserverState()

    static let selfieCloseUpZoom: CGFloat = 1.3

    // MARK: - Init

    override public init() {
        super.init()
        setupAppLifecycleObservers()
    }

    deinit {
        if let bg = observerState.backgroundObserver {
            NotificationCenter.default.removeObserver(bg)
        }
        if let fg = observerState.foregroundObserver {
            NotificationCenter.default.removeObserver(fg)
        }
        observerState.lensSwitchObservation?.invalidate()
    }

    // MARK: - Public 메서드

    public func clearError() {
        errorMessage = nil
    }

    public func startSession() async throws {
        do {
            try await configureSession()
            await startRunning()
            let zoom = currentZoomFactor
            try setZoomOnDevice(zoom, animated: false)
        } catch {
            logger.error(message: "카메라 세션 시작 실패: \(error)")
            errorMessage = "카메라를 시작할 수 없습니다."
            throw error
        }
    }

    public func stopSession() async {
        await stopAndReset()
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
        let flashOn = isFlashOn
        mutableState.withLock { $0.flashMode = flashOn ? .on : .off }
    }

    public func switchCamera() async throws {
        do {
            try await switchCameraOnQueue()
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

    public nonisolated var captureSession: AVCaptureSession {
        session
    }
}
