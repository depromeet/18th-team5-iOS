//
//  CapturedResult.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct CapturedResult: Sendable, Equatable {
    public let imageData: Data
    public let capturedAt: Date
    public let cameraPosition: CameraPosition
    public let zoomLevel: Double

    public init(
        imageData: Data,
        capturedAt: Date,
        cameraPosition: CameraPosition,
        zoomLevel: Double
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
