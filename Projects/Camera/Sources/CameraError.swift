//
//  CameraError.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum CameraError: Error, Equatable {
    case deviceNotAvailable
    case cannotAddInput
    case cannotAddOutput
    case captureDataMissing
    case captureAlreadyInProgress
    case sessionStopped
    case sessionBusy
    case sessionStartFailed
    case switchFailed
    case captureFailed
}

extension CameraError {
    public var userMessage: String {
        switch self {
        case .deviceNotAvailable:
            "카메라를 사용할 수 없습니다."
        case .sessionStartFailed, .cannotAddInput, .cannotAddOutput:
            "카메라를 시작할 수 없습니다."
        case .switchFailed, .sessionBusy:
            "카메라 전환에 실패했습니다."
        case .captureFailed, .captureDataMissing:
            "사진 촬영에 실패했습니다."
        case .captureAlreadyInProgress:
            "이미 촬영이 진행 중입니다."
        case .sessionStopped:
            "카메라 세션이 종료되었습니다."
        }
    }
}

extension Notification.Name {
    static let cameraLensSwitched = Notification.Name("CameraLensSwitched")
}
