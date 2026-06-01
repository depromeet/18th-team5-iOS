//
//  NotificationRepositoryImpl.swift
//  Data
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import FirebaseMessaging
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
            },
            syncNotificationSettings: { settings in
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for (type, isEnabled) in settings {
                        let messaging = Messaging.messaging()
                        let topic = type.topic

                        group.addTask {
                            if isEnabled {
                                try await messaging.subscribe(toTopic: topic)
                            } else {
                                try await messaging.unsubscribe(fromTopic: topic)
                            }
                        }
                    }

                    try await group.waitForAll()
                }
            }
        )
    }
}
