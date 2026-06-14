//
//  CameraController+FocusExposure.swift
//  Camera
//
//  Created by Codex on 6/13/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import CoreGraphics

// MARK: - Focus & Exposure Control

extension CameraController {
    public func focusAndExpose(at devicePoint: CGPoint) throws {
        try focusAndExposeOnDevice(at: devicePoint)
    }

    public func setExposureBiasAdjustment(_ adjustment: Float) throws {
        try setExposureBiasAdjustmentOnDevice(adjustment)
    }

    public func resetFocusAndExposure() {
        do {
            try resetFocusAndExposureOnDevice()
        } catch {
            logger.warning(message: "초점/노출 초기화 실패: \(error)")
        }
    }

    nonisolated func focusAndExposeOnDevice(at devicePoint: CGPoint) throws {
        try sessionQueue.sync {
            guard let device = currentDevice() else {
                throw CameraError.deviceNotAvailable
            }

            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = devicePoint
            }

            if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            } else if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = devicePoint
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            } else if device.isExposureModeSupported(.autoExpose) {
                device.exposureMode = .autoExpose
            }

            let neutralBias = min(max(Float.zero, device.minExposureTargetBias), device.maxExposureTargetBias)
            device.setExposureTargetBias(neutralBias)

            mutableState.withLock {
                $0.exposureTargetBiasBase = neutralBias
            }
        }
    }

    nonisolated func setExposureBiasAdjustmentOnDevice(_ adjustment: Float) throws {
        try sessionQueue.sync {
            guard let device = currentDevice() else {
                throw CameraError.deviceNotAvailable
            }

            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            let base = mutableState.withLock { $0.exposureTargetBiasBase }
            let targetBias = min(
                max(base + adjustment, device.minExposureTargetBias),
                device.maxExposureTargetBias
            )
            device.setExposureTargetBias(targetBias)
        }
    }

    nonisolated func resetFocusAndExposureOnDevice() throws {
        try sessionQueue.sync {
            guard let device = currentDevice() else {
                throw CameraError.deviceNotAvailable
            }

            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            let neutralBias = min(max(Float.zero, device.minExposureTargetBias), device.maxExposureTargetBias)
            device.setExposureTargetBias(neutralBias)

            mutableState.withLock {
                $0.exposureTargetBiasBase = neutralBias
            }
        }
    }
}
