//
//  UserType+.swift
//  Data
//
//  Created by 이정원 on 5/28/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension UserType {
    init?(_ value: String?) {
        guard let value else { return nil }

        switch value {
        case "EXPLORER": self = .explorer
        case "WALKER": self = .walker
        case "LIFE_CREATOR": self = .lifeCreator
        case "AESTHETE": self = .aesthete
        default: return nil
        }
    }
}
