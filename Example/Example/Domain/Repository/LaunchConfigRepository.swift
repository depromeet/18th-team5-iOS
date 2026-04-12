//
//  LaunchConfigRepository.swift
//  Domain
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public final class LaunchConfigRepository {
    public private(set) var fetch: () async throws -> LaunchConfig

    public init(
        fetch: @escaping () async throws -> LaunchConfig
    ) {
        self.fetch = fetch
    }
}
