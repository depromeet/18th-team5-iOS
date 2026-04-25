//
//  LaunchConfigRepository.swift
//  Domain
//
//  Created by choijunios on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct LaunchConfigRepository: Sendable {
    public var fetch: @Sendable () async throws -> LaunchConfig
}

// MARK: - TestDependencyKey

extension LaunchConfigRepository: TestDependencyKey {
    public static let testValue = LaunchConfigRepository()
}

public extension DependencyValues {
    var launchConfigRepository: LaunchConfigRepository {
        get { self[LaunchConfigRepository.self] }
        set { self[LaunchConfigRepository.self] = newValue }
    }
}

public extension LaunchConfigRepository {
    static let previewValue = LaunchConfigRepository(
        fetch: {
            LaunchConfig(
                maintenance: false,
                isForceUpdateEnabled: false,
                minimumAppVersion: AppVersion(version: "0.0.0") ?? AppVersion(major: 0, minor: 0, patch: 0),
                appStoreLink: ""
            )
        }
    )
}
