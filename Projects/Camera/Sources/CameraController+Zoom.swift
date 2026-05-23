//
//  CameraController+Zoom.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation

// MARK: - Zoom Device Control

extension CameraController {
    nonisolated func setZoomOnDevice(_ factor: CGFloat, animated: Bool) throws {
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
}
