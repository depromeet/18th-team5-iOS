//
//  NotificationSettingsRequestDTO.swift
//  Data
//
//  Created by 이정원 on 6/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

struct NotificationSettingsRequestDTO: Encodable {
    let dailyMission: Bool?
    let solarTermStart: Bool?
    let solarTermEnd: Bool?

    init(settings: [NotificationType: Bool]) {
        self.dailyMission = settings[.dailyMission]
        self.solarTermStart = settings[.solarTermStart]
        self.solarTermEnd = settings[.solarTermEnd]
    }
}
