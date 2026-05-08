//
//  TokenRepository.swift
//  Domain
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct TokenRepository: Sendable {
    public var setDebugDeviceToken: @Sendable (_ token: String) -> Void?
}

// MARK: - TestDependencyKey

extension TokenRepository: TestDependencyKey {
    public static let testValue = TokenRepository()
}

public extension DependencyValues {
    var tokenRepository: TokenRepository {
        get { self[TokenRepository.self] }
        set { self[TokenRepository.self] = newValue }
    }
}
