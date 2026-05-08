//
//  OnboardingRepository.swift
//  Domain
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros

@DependencyClient
public struct OnboardingRepository: Sendable {
    public var isOnboarded: @Sendable () async throws -> Bool
}

// MARK: - TestDependencyKey

extension OnboardingRepository: TestDependencyKey {
    public static let testValue = OnboardingRepository()
}

public extension DependencyValues {
    var onboardingRepository: OnboardingRepository {
        get { self[OnboardingRepository.self] }
        set { self[OnboardingRepository.self] = newValue }
    }
}
