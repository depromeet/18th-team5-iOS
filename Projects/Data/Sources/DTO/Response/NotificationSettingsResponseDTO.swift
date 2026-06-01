//
//  NotificationSettingsResponseDTO.swift
//  Data
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

struct NotificationSettingsResponseDTO: Decodable {
    let dailyMission: Bool?
    let solarTermEnd: Bool?
    let solarTermStart: Bool?
}

extension NotificationSettingsResponseDTO {
    var toDomain: [NotificationType: Bool]? {
        guard let dailyMission,
              let solarTermEnd,
              let solarTermStart else {
            return nil
        }

        return [
            .dailyMission: dailyMission,
            .solarTermEnd: solarTermEnd,
            .solarTermStart: solarTermStart
        ]
    }
}
