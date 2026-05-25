//
//  NotificationClientImpl.swift
//  Data
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import UIKit
import UserNotifications

extension NotificationClient: @retroactive DependencyKey {
    public static let liveValue: NotificationClient = NotificationClientImpl.live()
}

public enum NotificationClientImpl {
    public static func live() -> NotificationClient {
        NotificationClient(
            getAuthorizationStatus: {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                return settings.authorizationStatus.toDomain()
            },
            requestAuthorization: {
                try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .badge, .sound])
            },
            requestProvisionalAuthorization: {
                try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.provisional])
            },
            registerForRemoteNotifications: {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        )
    }
}

// MARK: - Mapping

extension UNAuthorizationStatus {
    func toDomain() -> NotificationAuthorizationStatus {
        switch self {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized, .ephemeral: return .authorized
        case .provisional: return .provisional
        @unknown default: return .notDetermined
        }
    }
}
