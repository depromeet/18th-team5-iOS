//
//  OnboardingRepository.swift
//  Domain
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct OnboardingRepository: Sendable {
    public var isOnboardingCompleted: @Sendable () throws -> Bool
    public var setOnboardingCompleted: @Sendable () throws -> Void
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
