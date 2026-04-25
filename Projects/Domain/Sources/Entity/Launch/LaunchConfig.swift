//
//  LaunchConfig.swift
//  Domain
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct LaunchConfig: Equatable {
    public let maintenance: Bool
    public let isForceUpdateEnabled: Bool
    public let minimumAppVersion: AppVersion
    public let appStoreLink: String

    public init(
        maintenance: Bool,
        isForceUpdateEnabled: Bool,
        minimumAppVersion: AppVersion,
        appStoreLink: String
    ) {
        self.maintenance = maintenance
        self.isForceUpdateEnabled = isForceUpdateEnabled
        self.minimumAppVersion = minimumAppVersion
        self.appStoreLink = appStoreLink
    }
}
