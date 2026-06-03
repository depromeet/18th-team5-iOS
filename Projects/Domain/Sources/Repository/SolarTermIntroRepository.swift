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
    /// Firebase Storage에서 절기 소개 JSON을 다운로드하여 절기 카드 목록을 반환
    public var fetchSolarTermCard: @Sendable () async throws -> [SolarTermIntro]
    /// Firebase Storage 경로 -> 이미지 다운로드 URL을 반환
    public var fetchImageURL: @Sendable (_ path: String) async throws -> URL
    /// 콘텐츠 목록의 이미지 경로 -> Firebase Storage 다운로드 URL로 변환
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
