//
//  NotificationRepository.swift
//  Domain
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct NotificationRepository: Sendable {
    public var fetchNotificationSettings: @Sendable () async throws -> [NotificationType: Bool]?
    public var syncNotificationSettings: @Sendable ([NotificationType: Bool]) async throws -> Void
}

extension NotificationRepository: TestDependencyKey {
    public static let testValue = NotificationRepository()
}

public extension DependencyValues {
    var notificationRepository: NotificationRepository {
        get { self[NotificationRepository.self] }
        set { self[NotificationRepository.self] = newValue }
    }
}
