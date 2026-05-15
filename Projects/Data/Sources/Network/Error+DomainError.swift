//
//  Error+DomainError.swift
//  Data
//
//  Created by 진준호 on 4/20/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

// MARK: - NetworkError → DomainError

extension NetworkError {
    func toDomainError() -> DomainError {
        switch self {
        case .invalidURL, .encodingFailed:
            return .invalidRequest(nil)
        case let .requestFailed(statusCode):
            switch statusCode {
            case 400, 422:
                return .invalidRequest(nil)
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500 ... 599:
                return .serverError
            default:
                return .unknown("HTTP \(statusCode)")
            }
        case .decodingFailed:
            return .dataCorrupted
        case .networkUnavailable:
            return .serviceUnavailable
        case let .unknown(message):
            return .unknown(message)
        }
    }
}

// MARK: - ServerDomainError → DomainError

extension ServerDomainError {
    func toDomainError() -> DomainError {
        switch self {
        case .common400:
            return .invalidRequest(message)
        case .common401, .auth401, .auth401Expired, .auth401RT, .auth401Mismatch:
            return .unauthorized
        case let .unknown(code, message):
            return .unknown("[\(code)] \(message)")
        }
    }
}

// MARK: - DTOMappingError → DomainError

extension DTOMappingError {
    func toDomainError() -> DomainError {
        .dataCorrupted
    }
}

// MARK: - Error → DomainError (Repository catch 블록용)

/// Repository의 catch 블록에서 에러를 DomainError로 변환하는 헬퍼
/// - DomainError는 그대로 패스스루
/// - NetworkError, DTOMappingError는 각 타입의 toDomainError() 사용
/// - 그 외는 .unknown으로 변환
func mapToDomainError(_ error: Error) -> DomainError {
    if let domainError = error as? DomainError {
        return domainError
    }
    if let serverError = error as? ServerDomainError {
        return serverError.toDomainError()
    }
    if let networkError = error as? NetworkError {
        return networkError.toDomainError()
    }
    if let mappingError = error as? DTOMappingError {
        return mappingError.toDomainError()
    }
    return .unknown(error.localizedDescription)
}
