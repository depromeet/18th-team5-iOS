//
//  CameraController+Helpers.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation

// MARK: - Device Helpers

extension CameraController {
    nonisolated func cameraDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
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

    nonisolated func currentDevice() -> AVCaptureDevice? {
        (session.inputs.first as? AVCaptureDeviceInput)?.device
    }

    nonisolated func configureLensSwitching(for device: AVCaptureDevice) {
        observerState.lensSwitchObservation?.invalidate()
        observerState.lensSwitchObservation = nil

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

        observerState.lensSwitchObservation = device.observe(\.activePrimaryConstituent) { _, _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .cameraLensSwitched, object: nil)
            }
        }
    }
}
