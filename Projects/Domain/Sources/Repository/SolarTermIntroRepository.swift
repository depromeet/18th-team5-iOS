//
//  SolarTermIntroRepository.swift
//  Domain
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct SolarTermIntroRepository: Sendable {
    public var fetchSolarTermCard: @Sendable () async throws -> [SolarTermIntro]
    public var fetchSolarTermInfos: @Sendable () async throws -> [SolarTermInfo]
}

extension SolarTermIntroRepository: TestDependencyKey {
    public static let testValue = SolarTermIntroRepository()
}

public extension DependencyValues {
    var solarTermIntroRepository: SolarTermIntroRepository {
        get { self[SolarTermIntroRepository.self] }
        set { self[SolarTermIntroRepository.self] = newValue }
    }
}

public extension SolarTermIntroRepository {
    static let previewValue = SolarTermIntroRepository(
        fetchSolarTermCard: { SolarTermIntro.mockList },
        fetchSolarTermInfos: { [] }
    )
}
