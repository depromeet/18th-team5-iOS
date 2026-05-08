//
//  OnboardingRepositoryImpl.swift
//  Data
//
//  Created by Claude on 5/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

// MARK: - DependencyKey

extension OnboardingRepository: @retroactive DependencyKey {
    public static let liveValue: OnboardingRepository = OnboardingRepositoryImpl.live()
}

// MARK: - liveValue

enum OnboardingRepositoryImpl {
    static func live() -> OnboardingRepository {
        @Dependency(\.networkClient) var networkClient
        return OnboardingRepository(
            isOnboarded: {
                do {
                    let response: UserInfoResponseDTO? = try await networkClient.request(
                        UserEndpoint.fetchUserInfo
                    )

                    guard let response else {
                        throw DomainError.unknown("데이터 획득불가")
                    }

                    return response.onboardingCompleted
                } catch {
                    throw mapToDomainError(error)
                }
            }
        )
    }
}
