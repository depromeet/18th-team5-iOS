//
//  SolarTermRepository.swift
//  Domain
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct SolarTermRepository: Sendable {
    public var fetchSolarTerms: @Sendable (_ year: SolarTermYear) async throws -> [SolarTermInfo]
}

extension SolarTermRepository: TestDependencyKey {
    public static let testValue = SolarTermRepository()
}

public extension DependencyValues {
    var solarTermRepository: SolarTermRepository {
        get { self[SolarTermRepository.self] }
        set { self[SolarTermRepository.self] = newValue }
    }
}
