//
//  ZoomLevel.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum ZoomLevel: CGFloat, CaseIterable, Equatable, Sendable {
    // swiftlint:disable:next identifier_name
    case x0_5 = 0.5
    case x1 = 1.0
    case x2 = 2.0
    case x3 = 3.0

    public var displayText: String {
        switch self {
        case .x0_5: ".5"
        case .x1: "1"
        case .x2: "2"
        case .x3: "3"
        }
    }
}

extension CameraController {
    public var activePreset: ZoomLevel {
        if currentZoomFactor < 1.0 {
            return .x0_5
        } else if currentZoomFactor < 2.0 {
            return .x1
        } else if currentZoomFactor < 3.0 {
            return .x2
        } else {
            return .x3
        }
    }

    public var zoomButtonTexts: [ZoomLevel: String] {
        var result: [ZoomLevel: String] = [:]
        for level in ZoomLevel.allCases {
            if activePreset == level {
                if currentZoomFactor < 1.0 {
                    let digit = Int(round(currentZoomFactor * 10)) % 10
                    result[level] = ".\(digit)x"
                } else {
                    let intPart = Int(currentZoomFactor)
                    let fraction = currentZoomFactor - CGFloat(intPart)
                    if fraction < 0.05 {
                        result[level] = "\(intPart)x"
                    } else {
                        result[level] = String(format: "%.1fx", currentZoomFactor)
                    }
                }
            } else {
                result[level] = level.displayText
            }
        }
        return result
    }
}
