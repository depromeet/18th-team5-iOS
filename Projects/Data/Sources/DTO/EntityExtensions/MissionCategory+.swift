//
//  MissionCategory+.swift
//  Data
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension MissionCategory {
    init?(_ value: String?) {
        guard let value else { return nil }

        switch value {
        case "FOOD": self = .food
        case "NATURE": self = .nature
        case "RECORD": self = .record
        case "PLACE": self = .place
        case "SENSE": self = .music
        default: return nil
        }
    }
}
