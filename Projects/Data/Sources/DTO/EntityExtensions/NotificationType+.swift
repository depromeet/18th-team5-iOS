//
//  NotificationType+.swift
//  Data
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension NotificationType {
    var topic: String {
        switch self {
        case .dailyMission: "daily_mission"
        case .solarTermEnd: "solar_term_end"
        case .solarTermStart: "solar_term_start"
        }
    }
}
