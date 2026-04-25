//
//  OnboardingStorage.swift
//  Data
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension OnboardingRepository: @retroactive DependencyKey {
    public static let liveValue: OnboardingRepository = OnboardingStorage.live()
}

public enum OnboardingStorage {
    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    public static func live() -> OnboardingRepository {
        OnboardingRepository(
            isOnboardingCompleted: {
                UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
            },
            setOnboardingCompleted: {
                UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
            }
        )
    }
}
