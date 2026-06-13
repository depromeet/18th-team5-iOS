//
//  RecordCardType+.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension RecordCardType {
    init?(_ value: String?) {
        guard let value else { return nil }
        let type = RecordCardType.allCases.first { $0.value == value }
        guard let type else { return nil }
        self = type
    }

    var value: String {
        switch self {
        case .daily: "DAILY"
        case .recommended: "RECOMMENDED"
        case .selected: "SELECTED"
        case .free: "FREE"
        }
    }
}
