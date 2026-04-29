//
//  NotificationClient.swift
//  Domain
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

public enum NotificationAuthorizationStatus: Sendable, Equatable {
    case notDetermined, denied, authorized, provisional
}

@DependencyClient
public struct NotificationClient: Sendable {
    public var getAuthorizationStatus: @Sendable () async throws -> NotificationAuthorizationStatus
    public var requestAuthorization: @Sendable () async throws -> Bool
    public var requestProvisionalAuthorization: @Sendable () async throws -> Void
}

// MARK: - TestDependencyKey

extension NotificationClient: TestDependencyKey {
    public static let testValue = NotificationClient()
}

public extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
