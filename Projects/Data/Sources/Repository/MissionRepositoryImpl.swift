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
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    fileprivate static let iso8601FallbackFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()

    fileprivate static func parseDate(from string: String) -> Date? {
        iso8601Formatter.date(from: string) ?? iso8601FallbackFormatter.date(from: string)
    }

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
                    let result: MissionCompleteResultDTO? = try await client.request(
                        MissionEndpoint.complete(missionId: missionId, request: requestDTO)
                    )
                    guard let result else {
                        throw DomainError.unknown("데이터 획득 실패")
                    }
                    return try result.toDomain()
                } catch {
                    throw mapToDomainError(error)
                }
            },
            fetchCompletions: { missionId in
                @Dependency(\.networkClient) var client

                do {
                    let result: [MissionCompletionItemDTO]? = try await client.request(
                        MissionEndpoint.fetchCompletions(missionId: missionId)
                    )
                    guard let result else {
                        throw DomainError.unknown("데이터 획득 실패")
                    }
                    return try result.map { try $0.toDomain() }
                } catch {
                    throw mapToDomainError(error)
                }
            },
            uploadImage: { imageData, fileName, contentType in
                @Dependency(\.s3Client) var s3Client

                do {
                    let (presignedUrl, objectKey) = try await s3Client.fetchPresignedUrl(
                        fileName,
                        contentType
                    )
                    try await s3Client.uploadImage(presignedUrl, imageData, contentType)
                    return objectKey
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
        guard let date = MissionRepositoryImpl.parseDate(from: completedAt) else {
            throw DTOMappingError.invalidDateFormat(completedAt)
        }

        return MissionCompletion(
            completionId: completionId,
            missionId: missionId,
            missionType: missionType,
            // complete 응답에는 objectKey/presignedImageUrl/memo가 포함되지 않음
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
        guard let date = MissionRepositoryImpl.parseDate(from: completedAt) else {
            throw DTOMappingError.invalidDateFormat(completedAt)
        }
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
