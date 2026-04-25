//
//  AuthRepository.swift
//  Domain
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AuthRepository: Sendable {
    public var login: @Sendable () async throws -> Void
}

// MARK: - TestDependencyKey

extension AuthRepository: TestDependencyKey {
    public static let testValue = AuthRepository()
}

public extension DependencyValues {
    var authRepository: AuthRepository {
        get { self[AuthRepository.self] }
        set { self[AuthRepository.self] = newValue }
    }
}
