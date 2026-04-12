//
//  LaunchConfigRepositoryImpl.swift
//  Data
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain

public struct LaunchConfigRepositoryKey: DependencyKey {
    public static var liveValue: LaunchConfigRepository {
        LaunchConfigRepository(
            fetch: {
                return LaunchConfig(
                    maintenance: true,
                    minimumAppVersion: .current!
                )
            }
        )
    }
}

public extension DependencyValues {
    var launchConfigRepository: LaunchConfigRepository {
        get { self[LaunchConfigRepositoryKey.self] }
        set { self[LaunchConfigRepositoryKey.self] = newValue }
    }
}
