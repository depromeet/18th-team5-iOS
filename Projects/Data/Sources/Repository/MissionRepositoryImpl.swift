//
//  MissionRepositoryImpl.swift
//  Data
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension MissionRepository: @retroactive DependencyKey {
    public static let liveValue: MissionRepository = MissionRepositoryImpl.live()
}

public enum MissionRepositoryImpl {
    fileprivate static let iso8601Formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    public static func live() -> MissionRepository {
        MissionRepository(
            completeMission: { missionId, missionType, objectKey, memo, completedAt in
                @Dependency(\.networkClient) var client

                let completedAtString = completedAt.map { iso8601Formatter.string(from: $0) }
                let requestDTO = MissionCompleteRequestDTO(
                    missionType: missionType.rawValue,
                    objectKey: objectKey,
                    memo: memo,
                    completedAt: completedAtString
                )

                do {
                    let response: MissionCompleteResponseDTO = try await client.request(
                        MissionEndpoint.complete(missionId: missionId, request: requestDTO)
                    )
                    return try response.result.toDomain()
                } catch {
                    throw mapToDomainError(error)
                }
            },
            fetchCompletions: { missionId in
                @Dependency(\.networkClient) var client

                do {
                    let response: MissionCompletionsResponseDTO = try await client.request(
                        MissionEndpoint.fetchCompletions(missionId: missionId)
                    )
                    return try response.result.map { try $0.toDomain() }
                } catch {
                    throw mapToDomainError(error)
                }
            }
        )
    }
}

// MARK: - Domain Mapping

private extension MissionCompleteResultDTO {
    func toDomain() throws -> MissionCompletion {
        guard let missionType = MissionType(rawValue: missionType) else {
            throw DTOMappingError.invalidValue(missionType)
        }
        let date = MissionRepositoryImpl.iso8601Formatter.date(from: completedAt) ?? Date()

        return MissionCompletion(
            completionId: completionId,
            missionId: missionId,
            missionType: missionType,
            objectKey: nil,
            presignedImageUrl: nil,
            memo: nil,
            completedAt: date
        )
    }
}

private extension MissionCompletionItemDTO {
    func toDomain() throws -> MissionCompletion {
        guard let missionType = MissionType(rawValue: missionType) else {
            throw DTOMappingError.invalidValue(missionType)
        }
        let date = MissionRepositoryImpl.iso8601Formatter.date(from: completedAt) ?? Date()
        let imageUrl = presignedImageUrl.flatMap { URL(string: $0) }

        return MissionCompletion(
            completionId: completionId,
            missionId: missionId,
            missionType: missionType,
            objectKey: objectKey,
            presignedImageUrl: imageUrl,
            memo: memo,
            completedAt: date
        )
    }
}
