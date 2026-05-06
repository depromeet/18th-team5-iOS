//
//  CapturedPhoto.swift
//  Domain
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct CapturedPhoto: Equatable, Sendable {
    public let imageData: Data
    public let capturedAt: Date
    public let cameraPosition: CameraPosition
    public let zoomLevel: CGFloat

    public init(
        imageData: Data,
        capturedAt: Date,
        cameraPosition: CameraPosition,
        zoomLevel: CGFloat
    ) {
        self.imageData = imageData
        self.capturedAt = capturedAt
        self.cameraPosition = cameraPosition
        self.zoomLevel = zoomLevel
    }
}

public enum CameraPosition: Sendable, Equatable {
    case front
    case back
}
