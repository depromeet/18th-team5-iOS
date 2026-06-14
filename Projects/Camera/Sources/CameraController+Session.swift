//
//  CameraController+Session.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation

// MARK: - Session Management

extension CameraController {
    func configureSession() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [self] in
                do {
                    try configureSessionGuarded()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @discardableResult
    nonisolated func configureSessionGuarded() throws -> Bool {
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

    nonisolated func configureSessionOnQueue() throws {
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

    func startRunning() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [self] in
                if !session.isRunning {
                    session.startRunning()
                }
                continuation.resume()
            }
        }
        isSessionRunning = true
    }

    func stopAndReset() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [self] in
                let shouldStop = mutableState.withLock { state -> Bool in
                    guard state.sessionPhase == .running else { return false }
                    state.sessionPhase = .stopping
                    state.currentPosition = .back
                    state.flashMode = .off
                    state.exposureTargetBiasBase = 0
                    return true
                }

                if shouldStop {
                    teardownSession()
                    mutableState.withLock { $0.sessionPhase = .idle }
                }
                continuation.resume()
            }
        }

        isFlashOn = false
        isFrontCamera = false
        currentZoomFactor = 1.0
        baseZoomFactor = 1.0
        isSessionRunning = false
    }

    nonisolated func teardownSession() {
        let pendingContinuation = mutableState.withLock { state -> CheckedContinuation<CapturedResult, Error>? in
            let result = state.photoContinuation
            state.photoContinuation = nil
            return result
        }
        pendingContinuation?.resume(throwing: CameraError.sessionStopped)

        observerState.lensSwitchObservation?.invalidate()
        observerState.lensSwitchObservation = nil
        session.stopRunning()
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()
    }

    func switchCameraOnQueue() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [self] in
                mutableState.withLock {
                    $0.currentPosition = ($0.currentPosition == .back) ? .front : .back
                }
                do {
                    let configured = try configureSessionGuarded()
                    guard configured else { throw CameraError.sessionBusy }
                    continuation.resume()
                } catch {
                    mutableState.withLock {
                        $0.currentPosition = ($0.currentPosition == .back) ? .front : .back
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
