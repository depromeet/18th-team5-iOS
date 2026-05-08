//
//  TokenRepository.swift
//  Domain
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

public struct TokenRepository: Sendable {
    public var hasTokens: @Sendable () -> Bool
    public var setDebugDeviceToken: @Sendable (_ token: String) -> Void
    public init(
        hasTokens: @Sendable @escaping () -> Bool,
        setDebugDeviceToken: @Sendable @escaping (_ token: String) -> Void = { _ in }
    ) {
        self.hasTokens = hasTokens
        self.setDebugDeviceToken = setDebugDeviceToken
    }
}

// MARK: - TestDependencyKey

extension TokenRepository: TestDependencyKey {
    public static let testValue = TokenRepository(hasTokens: { return true })
}

public extension DependencyValues {
    var tokenRepository: TokenRepository {
        get { self[TokenRepository.self] }
        set { self[TokenRepository.self] = newValue }
    }
}
