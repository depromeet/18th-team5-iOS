//
//  HomeRepositoryImpl.swift
//  Data
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension HomeRepository: @retroactive DependencyKey {
    public static let liveValue: HomeRepository = HomeRepositoryImpl.live()
}

public enum HomeRepositoryImpl {
    public static func live() -> HomeRepository {
        HomeRepository(
            fetchCard: {
                @Dependency(\.networkClient) var networkClient
                do {
                    let response: HomeCardDTO? = try await networkClient.request(
                        HomeEndpoint.card
                    )
                    guard let response else {
                        throw DomainError.unknown("데이터 수신 실패")
                    }
                    return response.toDomain()
                } catch {
                    throw mapToDomainError(error)
                }
            },
            fetchSeasonalRecords: {
                @Dependency(\.networkClient) var networkClient
                do {
                    let response: HomeSeasonRecordResponseDTO? = try await networkClient.request(
                        HomeEndpoint.seasonalRecords
                    )
                    guard let response else {
                        throw DomainError.unknown("데이터 수신 실패")
                    }
                    return response.toDomain()
                } catch {
                    throw mapToDomainError(error)
                }
            }
        )
    }
}
