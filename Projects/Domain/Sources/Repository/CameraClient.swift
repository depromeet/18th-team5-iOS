//
//  CameraClient.swift
//  Domain
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct CameraClient: Sendable {
    public var startSession: @Sendable () async throws -> Void
    public var stopSession: @Sendable () async -> Void
    public var capturePhoto: @Sendable () async throws -> CapturedPhoto
    public var switchCamera: @Sendable () async throws -> Void
    public var setZoomFactor: @Sendable (_ factor: CGFloat, _ animated: Bool) async throws -> Void
    public var setFlashMode: @Sendable (_ isOn: Bool) async -> Void
    public var getSession: @Sendable () -> AVCaptureSession = { AVCaptureSession() }
}

// MARK: - TestDependencyKey

extension CameraClient: TestDependencyKey {
    public static let testValue = CameraClient()
}

public extension DependencyValues {
    var cameraClient: CameraClient {
        get { self[CameraClient.self] }
        set { self[CameraClient.self] = newValue }
    }
}
