//
//  ServerDomainError.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// 서버에서 정의한 에러 코드를 나타내는 에러 타입.
/// 서버 응답 Body의 `code`, `message` 필드를 파싱하여 생성합니다.
enum ServerDomainError: Error, Equatable {
    case common400(message: String)
    case common401(message: String)
    case auth401(message: String)
    case auth401Expired(message: String)
    case auth401RT(message: String)
    case auth401Mismatch(message: String)
    case unknown(code: String, message: String)

    var code: String {
        switch self {
        case .common400: "COMMON_400"
        case .common401: "COMMON_401"
        case .auth401: "AUTH_401"
        case .auth401Expired: "AUTH_401_EXPIRED"
        case .auth401RT: "AUTH_401_RT"
        case .auth401Mismatch: "AUTH_401_MISMATCH"
        case let .unknown(code, _): code
        }
    }

    var message: String {
        switch self {
        case let .common400(message): message
        case let .common401(message): message
        case let .auth401(message): message
        case let .auth401Expired(message): message
        case let .auth401RT(message): message
        case let .auth401Mismatch(message): message
        case let .unknown(_, message): message
        }
    }

    static func from(code: String, message: String) -> ServerDomainError {
        switch code {
        case "COMMON_400":
            return .common400(message: message)
        case "COMMON_401":
            return .common401(message: message)
        case "AUTH_401":
            return .auth401(message: message)
        case "AUTH_401_EXPIRED":
            return .auth401Expired(message: message)
        case "AUTH_401_RT":
            return .auth401RT(message: message)
        case "AUTH_401_MISMATCH":
            return .auth401Mismatch(message: message)
        default:
            return .unknown(code: code, message: message)
        }
    }

    /// AUTH_401_* 계열 에러인지 여부.
    /// refresh token이 만료되었거나 유효하지 않아 재시도가 불가능한 상태입니다.
    var isAuthRefreshError: Bool {
        switch self {
        case .auth401, .auth401Expired, .auth401RT, .auth401Mismatch:
            return true
        default:
            return false
        }
    }
}
