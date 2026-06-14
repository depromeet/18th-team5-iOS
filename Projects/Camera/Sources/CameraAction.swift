//
//  CameraAction.swift
//  Camera
//
//  Created by 진준호 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import CoreGraphics
import Foundation

// MARK: - Presentation → Camera 명령

public enum CameraAction {
    case startSession
    case stopSession
    case switchCamera
    case capturePhoto
    case toggleFlash
    case setZoom(factor: CGFloat, animated: Bool)
    case setZoomFromPinch(magnification: CGFloat)
    case endPinchZoom
    case toggleSelfieZoom
    case focusAndExpose(at: CGPoint)
    case setExposureBiasAdjustment(Float)
    case resetFocusAndExposure
}

// MARK: - Camera → Presentation 상태 전달

public struct CameraStateSnapshot: Equatable, Sendable {
    public let isFrontCamera: Bool
    public let isFlashOn: Bool
    public let currentZoomFactor: CGFloat
    public let isSwitchingCamera: Bool
    public let isSessionRunning: Bool
    public let activePreset: ZoomLevel
    public let zoomButtonTexts: [ZoomLevel: String]

    public init(
        isFrontCamera: Bool,
        isFlashOn: Bool,
        currentZoomFactor: CGFloat,
        isSwitchingCamera: Bool,
        isSessionRunning: Bool,
        activePreset: ZoomLevel,
        zoomButtonTexts: [ZoomLevel: String]
    ) {
        self.isFrontCamera = isFrontCamera
        self.isFlashOn = isFlashOn
        self.currentZoomFactor = currentZoomFactor
        self.isSwitchingCamera = isSwitchingCamera
        self.isSessionRunning = isSessionRunning
        self.activePreset = activePreset
        self.zoomButtonTexts = zoomButtonTexts
    }

    public static let initial = CameraStateSnapshot(
        isFrontCamera: false,
        isFlashOn: false,
        currentZoomFactor: 1.0,
        isSwitchingCamera: false,
        isSessionRunning: false,
        activePreset: .x1,
        zoomButtonTexts: [:]
    )
}

// MARK: - Presentation ↔ Camera 연결 프록시

public typealias CameraActionHandler = (CameraAction) -> Void

public final class CameraProxy: @unchecked Sendable {
    var handler: CameraActionHandler?

    public init() {}

    public func send(_ action: CameraAction) {
        handler?(action)
    }
}
