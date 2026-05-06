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
import UIKit

// MARK: - DependencyKey

extension CameraClient: @retroactive DependencyKey {
    public static let liveValue: CameraClient = CameraClientImpl.live()
}

// MARK: - CameraClientImpl

private final class CameraClientImpl: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    private var flashMode: AVCaptureDevice.FlashMode = .off
    private var photoContinuation: CheckedContinuation<CapturedPhoto, Error>?
    private var lensSwitchObservation: NSKeyValueObservation?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?
    private var wasRunningBeforeBackground = false

    static func live() -> CameraClient {
        let manager = CameraClientImpl()
        manager.setupAppLifecycleObservers()

        return CameraClient(
            startSession: {
                try manager.configureSession()
                manager.startRunning()
            },
            stopSession: {
                manager.stopRunning()
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
                manager.flashMode = isOn ? .on : .off
            },
            getSession: {
                manager.session
            }
        )
    }

    // MARK: - Session Configuration

    private func configureSession() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .high

        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        guard let device = cameraDevice(for: currentPosition),
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
        guard !session.isRunning else { return }
        session.startRunning()
    }

    private func stopRunning() {
        guard session.isRunning else { return }
        lensSwitchObservation?.invalidate()
        lensSwitchObservation = nil
        session.stopRunning()

        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()
    }

    // MARK: - App Lifecycle

    private func setupAppLifecycleObservers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.session.isRunning else { return }
            self.wasRunningBeforeBackground = true
            self.stopRunning()
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.wasRunningBeforeBackground else { return }
            self.wasRunningBeforeBackground = false
            try? self.configureSession()
            self.startRunning()
        }
    }

    // MARK: - Capture

    private func capturePhoto() async throws -> CapturedPhoto {
        try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()
            if photoOutput.supportedFlashModes.contains(flashMode) {
                settings.flashMode = flashMode
            }

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - Switch Camera

    private func switchCamera() throws {
        currentPosition = (currentPosition == .back) ? .front : .back
        try configureSession()
    }

    // MARK: - Zoom

    private func setZoomFactor(_ factor: CGFloat, animated: Bool) throws {
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
        if let error {
            photoContinuation?.resume(throwing: error)
            photoContinuation = nil
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            photoContinuation?.resume(throwing: CameraError.captureDataMissing)
            photoContinuation = nil
            return
        }

        guard let originalImage = UIImage(data: data) else {
            photoContinuation?.resume(throwing: CameraError.captureDataMissing)
            photoContinuation = nil
            return
        }

        let squareImage = cropToSquare(originalImage)
        guard let squareData = squareImage.jpegData(compressionQuality: 0.9) else {
            photoContinuation?.resume(throwing: CameraError.captureDataMissing)
            photoContinuation = nil
            return
        }

        let device = currentDevice()
        let capturedPhoto = CapturedPhoto(
            imageData: squareData,
            capturedAt: Date(),
            cameraPosition: currentPosition == .front ? .front : .back,
            zoomLevel: device?.videoZoomFactor ?? 1.0
        )

        photoContinuation?.resume(returning: capturedPhoto)
        photoContinuation = nil
    }
}

// MARK: - CameraError

private enum CameraError: Error {
    case deviceNotAvailable
    case cannotAddInput
    case cannotAddOutput
    case captureDataMissing
}
