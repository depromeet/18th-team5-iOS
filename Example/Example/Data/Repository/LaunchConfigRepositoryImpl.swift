//
//  LaunchConfigRepositoryImpl.swift
//  Data
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import FirebaseRemoteConfig

// MARK: - Cache Dependency

private enum LaunchConfigCacheKey: DependencyKey {
    static let liveValue = MemoryCache<LaunchConfig>()
}

extension DependencyValues {
    var launchConfigCache: MemoryCache<LaunchConfig> {
        get { self[LaunchConfigCacheKey.self] }
        set { self[LaunchConfigCacheKey.self] = newValue }
    }
}

// MARK: - Live Implementation

extension LaunchConfigRepository: @retroactive DependencyKey {
    public static var liveValue: LaunchConfigRepository {
        LaunchConfigRepository(
            fetch: {
                @Dependency(\.launchConfigCache) var cache

                if let cached = await cache.value() {
                    return cached
                }

                let remoteConfig = RemoteConfig.remoteConfig()

                guard let _ = try? await remoteConfig.fetchAndActivate()
                else { throw LaunchConfigError.firebaseError }

                guard let json = remoteConfig["remote_config"].jsonValue as? [String: Any],
                      let dto = LaunchConfigResponseDTO(json: json)
                else { throw LaunchConfigError.unknown }

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
