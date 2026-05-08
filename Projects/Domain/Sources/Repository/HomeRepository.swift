//
//  HomeRepository.swift
//  Domain
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct HomeRepository: Sendable {
    public var fetchCard: @Sendable () async throws -> HomeCard
}

extension HomeRepository: TestDependencyKey {
    public static let testValue = HomeRepository()
}

public extension DependencyValues {
    var homeRepository: HomeRepository {
        get { self[HomeRepository.self] }
        set { self[HomeRepository.self] = newValue }
    }
}

public extension HomeRepository {
    static let previewValue = HomeRepository(
        fetchCard: { .mock }
    )
}
