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
    public var completeMission: @Sendable (
        _ missionId: Int,
        _ missionType: MissionType,
        _ objectKey: String?,
        _ memo: String?,
        _ completedAt: Date?
    ) async throws -> MissionCompletion

    public var fetchCompletions: @Sendable (_ missionId: Int) async throws -> [MissionCompletion]
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
