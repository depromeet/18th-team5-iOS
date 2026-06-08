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
            fetchMissionRecordPage: { missionId in
                @Dependency(\.networkClient) var client

                do {
                    let result: MissionRecordPageResponseDTO? = try await client.request(
                        MissionEndpoint.fetchRecordPage(missionId: missionId)
                    )
                    guard let result else {
                        throw DomainError.unknown("데이터 획득 실패")
                    }
                    return result.toDomain()
                } catch {
                    throw mapToDomainError(error)
                }
            },
            completeMission: { missionId, missionType, objectKey, memo in
                @Dependency(\.networkClient) var client

                let requestDTO = MissionCompleteRequestDTO(
                    objectKey: objectKey,
                    memo: memo
                )
                let endpoint = MissionEndpoint.complete(
                    missionId: missionId,
                    missionType: missionType,
                    request: requestDTO
                )

                do {
                    let result: MissionCompleteResultDTO? = try await client.request(
                        endpoint
                    )
                    guard let result else {
                        throw DomainError.unknown("데이터 획득 실패")
                    }
                    return result.completionId
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
            },
            fetchRecommendedMissions: {
                @Dependency(\.networkClient) var client

                do {
                    let endpoint = MissionEndpoint.fetchRecommendedMissions
                    let response: RecommendedMissionResponseDTO? = try await client.request(endpoint)
                    return response?.toDomain
                } catch {
                    throw mapToDomainError(error)
                }
            },
            fetchRecommendedMissionAvailability: {
                @Dependency(\.networkClient) var client

                do {
                    let endpoint = MissionEndpoint.fetchRecommendedMissionAvailability
                    let response: MissionAvailabilityResponseDTO? = try await client.request(endpoint)
                    return response?.toDomain ?? .init(isAvailable: nil, maxCount: nil)
                }
            },
            fetchSearchedMission: {
                @Dependency(\.networkClient) var client

                do {
                    let endpoint = MissionEndpoint.fetchSearchedMission
                    let response: SearchedMissionResponseDTO? = try await client.request(endpoint)
                    guard let response else { throw DomainError.nilResponse }

                    guard response.hasSelected == true else { return nil }
                    return response.mission?.searchedMission
                } catch {
                    throw mapToDomainError(error)
                }
            },
            searchMission: { attribute in
                @Dependency(\.networkClient) var client

                do {
                    let request = MissionSearchRequestDTO(attribute: attribute)
                    let endpoint = MissionEndpoint.searchMission(request: request)
                    let response: MissionResponseDTO? = try await client.request(endpoint)
                    return response?.searchedMission
                } catch {
                    throw mapToDomainError(error)
                }
            }
        )
    }
}

// MARK: - Domain Mapping

private extension MissionEndpoint {
    static func complete(
        missionId: Int,
        missionType: MissionType,
        request: MissionCompleteRequestDTO
    ) -> MissionEndpoint {
        switch missionType {
        case .daily:
            .completeDaily(missionId: missionId, request: request)
        case .recommended:
            .completeRecommended(missionId: missionId, request: request)
        case .selected:
            .completeSelected(missionId: missionId, request: request)
        }
    }
}

private extension MissionRecordPageResponseDTO {
    func toDomain() -> Mission {
        Mission(
            id: id,
            title: title,
            description: description
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
