//
//  LaunchConfigResponseDTO.swift
//  Data
//
//  Created by choijunios on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

struct LaunchConfigResponseDTO {
    let maintenance: Bool
    let isForceUpdateEnabled: Bool
    let minimumVersion: String
    let appStoreLink: String

    init?(json: [String: Any]) {
        guard let maintenance = json["isServerUnderMaintenance"] as? Bool,
              let isForceUpdateEnabled = json["isForceUpdateEnabled"] as? Bool,
              let minimumVersion = json["minimumSupportedVersion"] as? String,
              let appStoreLink = json["appStoreLink"] as? String
        else { return nil }

        self.maintenance = maintenance
        self.isForceUpdateEnabled = isForceUpdateEnabled
        self.minimumVersion = minimumVersion
        self.appStoreLink = appStoreLink
    }
}
