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

private let remoteConfigCache = MemoryCache<LaunchConfig>()

extension LaunchConfigRepository: @retroactive DependencyKey {
    public static let liveValue = LaunchConfigRepository(
        fetch: {
            if let cached = await remoteConfigCache.value() {
                return cached
            }

            let remoteConfig = RemoteConfig.remoteConfig()

            guard let _ = try? await remoteConfig.fetchAndActivate()
            else { throw LaunchConfigError.firebaseError }

            let maintenance = remoteConfig["maintenance"].boolValue
            let minimumApplicationVersion = remoteConfig["minimumApplicationVersion"].stringValue

            guard let minVersion = AppVersion(version: minimumApplicationVersion)
            else { throw LaunchConfigError.invalidVersionFormat }

            let config = LaunchConfig(
                maintenance: maintenance,
                minimumAppVersion: minVersion
            )
            await remoteConfigCache.set(value: config)
            return config
        }
    )
}
