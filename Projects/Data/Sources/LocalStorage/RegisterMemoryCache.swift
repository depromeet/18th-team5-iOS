//
//  RegisterMemoryCache.swift
//  Data
//
//  Created by choijunios on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain

private enum LaunchConfigCacheKey: DependencyKey {
    static let liveValue = SingleValueStore<LaunchConfig>()
}

extension DependencyValues {
    var launchConfigCache: SingleValueStore<LaunchConfig> {
        get { self[LaunchConfigCacheKey.self] }
        set { self[LaunchConfigCacheKey.self] = newValue }
    }
}
