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

    public init?(_ typeString: String?) {
        guard let typeString else { return nil }
        let type = NotificationType.allCases.first {
            $0.topic == typeString.lowercased()
        }

        guard let type else { return nil }
        self = type
    }
}
