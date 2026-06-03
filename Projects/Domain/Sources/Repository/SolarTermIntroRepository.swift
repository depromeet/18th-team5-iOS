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
    public var fetchImageURL: @Sendable (_ path: String) async throws -> URL
    public var fetchContentImageURLs: @Sendable (_ contents: [SolarTermIntroContent]) async -> [String: [URL]] = { _ in
        [:]
    }
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
        fetchImageURL: { _ in URL(string: "https://picsum.photos/400/300")! },
        fetchContentImageURLs: { _ in [:] }
    )
}
