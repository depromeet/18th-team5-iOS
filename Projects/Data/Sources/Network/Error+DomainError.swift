//
//  Error+DomainError.swift
//  Data
//
//  Created by 진준호 on 4/20/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

extension Error {
    func toDomainError() -> DomainError {
        if self is DTOMappingError {
            return .dataCorrupted
        }
        guard let networkError = self as? NetworkError else {
            return .unknown(localizedDescription)
        }
        switch networkError {
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
