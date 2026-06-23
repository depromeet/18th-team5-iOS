//
//  MissionTheme+.swift
//  Data
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension MissionTheme {
    init?(_ value: String?) {
        guard let value else { return nil }

        switch value {
        case "NATURE_OUTDOOR": self = .activity
        case "SEASONAL_FOOD": self = .food
        case "CULTURE_CONTENT": self = .contents
        default: return nil
        }
    }
}

extension MissionTheme {
    var analyticsValue: String {
        switch self {
        case .food: "food"
        case .contents: "contents"
        case .activity: "activity"
        }
    }
}
