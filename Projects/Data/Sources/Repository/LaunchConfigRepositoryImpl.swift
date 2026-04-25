//
//  LaunchConfigRepositoryImpl.swift
//  Data
//
//  Created by choijunios on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import FirebaseRemoteConfig

extension LaunchConfigRepository: @retroactive DependencyKey {
    public static let liveValue: LaunchConfigRepository = LaunchConfigRepositoryImpl.live()
}

public enum LaunchConfigRepositoryImpl {
    public static func live() -> LaunchConfigRepository {
        LaunchConfigRepository(
            fetch: {
                @Dependency(\.launchConfigCache) var cache

                let settings = RemoteConfigSettings()
                settings.minimumFetchInterval = 0
                settings.fetchTimeout = 10

                let remoteConfig = RemoteConfig.remoteConfig()
                remoteConfig.configSettings = settings

                let status = try await remoteConfig.fetchAndActivate()

                guard status == .successFetchedFromRemote else {
                    throw LaunchConfigError.firebaseError
                }

                guard let json = remoteConfig["remote_config"].jsonValue as? [String: Any],
                      let dto = LaunchConfigResponseDTO(json: json)
                else {
                    throw LaunchConfigError.unknown
                }

                let config = dto.toDomain()
                await cache.set(value: config)
                return config
            }
        )
    }
}

// MARK: - Domain Mapping

extension LaunchConfigResponseDTO {
    func toDomain() -> LaunchConfig {
        LaunchConfig(
            maintenance: maintenance,
            isForceUpdateEnabled: isForceUpdateEnabled,
            minimumAppVersion: AppVersion(version: minimumVersion) ?? .init(major: 0, minor: 0, patch: 0),
            appStoreLink: appStoreLink
        )
    }
}
