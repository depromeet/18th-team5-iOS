//
//  MissionRepository.swift
//  Domain
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct MissionRepository: Sendable {
    public var fetchMissionRecordPage: @Sendable (_ missionId: Int) async throws -> Mission

    public var completeMission: @Sendable (
        _ missionId: Int,
        _ missionType: MissionType,
        _ objectKey: String,
        _ memo: String?
    ) async throws -> Int

    public var fetchCompletions: @Sendable (_ missionId: Int) async throws -> [MissionCompletion]

    public var uploadImage: @Sendable (
        _ imageData: Data,
        _ fileName: String,
        _ contentType: String
    ) async throws -> String

    public var fetchRecommendedMissions: @Sendable () async throws -> RecommendedMission?
    public var fetchSearchedMission: @Sendable () async throws -> Mission?
    public var searchMission: @Sendable (_ attribute: MissionAttribute) async throws -> Mission?
}

extension MissionRepository: TestDependencyKey {
    public static let testValue = MissionRepository()
}

public extension DependencyValues {
    var missionRepository: MissionRepository {
        get { self[MissionRepository.self] }
        set { self[MissionRepository.self] = newValue }
    }
}
