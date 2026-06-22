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
        let type = ParticipationType.allCases.first { $0.value == value }
        guard let type else { return nil }
        self = type
    }

    var value: String {
        switch self {
        case .alone: "SOLO"
        case .together: "TOGETHER"
        }
    }
}
