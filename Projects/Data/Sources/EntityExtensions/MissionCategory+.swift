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
        let type = MissionCategory.allCases.first { $0.value == value }
        guard let type else { return nil }
        self = type
    }

    var value: String {
        switch self {
        case .food: "FOOD"
        case .nature: "NATURE"
        case .content: "CONTENT"
        case .place: "PLACE"
        case .music: "MUSIC"
        }
    }
}
