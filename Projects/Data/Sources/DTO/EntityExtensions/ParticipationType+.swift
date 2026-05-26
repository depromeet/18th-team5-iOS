//
//  ParticipationType+.swift
//  Data
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension ParticipationType {
    init?(_ value: String?) {
        guard let value else { return nil }

        switch value {
        case "ALONE": self = .alone
        case "TOGETHER": self = .together
        default: return nil
        }
    }
}
