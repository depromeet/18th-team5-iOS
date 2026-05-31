//
//  NotificationRepositoryImpl.swift
//  Data
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

// MARK: - DependencyKey

extension NotificationRepository: @retroactive DependencyKey {
    public static let liveValue: NotificationRepository = NotificationRepositoryImpl.live()
}

enum NotificationRepositoryImpl {
    static func live() -> NotificationRepository {
        NotificationRepository(
            fetchNotificationSettings: {
                @Dependency(\.networkClient) var client
                let endpoint = NotificationEndpoint.fetchNotificaitonInfo
                let response: NotificationSettingsResponseDTO? = try await client.request(endpoint)
                return response?.toDomain
            }
        )
    }
}
