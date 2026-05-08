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
            fetchHome: {
                @Dependency(\.networkClient) var client
                let response: HomeResponseDTO = try await client.request(
                    HomeEndpoint.fetchHome
                )
                return response.result.toDomain()
            }
        )
    }
}
