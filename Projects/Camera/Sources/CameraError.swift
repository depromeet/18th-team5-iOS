//
//  CameraError.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum CameraError: Error {
    case deviceNotAvailable
    case cannotAddInput
    case cannotAddOutput
    case captureDataMissing
    case captureAlreadyInProgress
    case sessionStopped
    case sessionBusy
}

extension Notification.Name {
    static let cameraLensSwitched = Notification.Name("CameraLensSwitched")
}
