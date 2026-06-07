//
//  CalendarAlertModel.swift
//  Presentation
//
//  Created by choijunios on 6/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Foundation

public struct CalendarAlertModel: Equatable {
    enum Button: Hashable {
        case confirm, close
    }

    let id = UUID()
    let message: String
    let buttons: [CustomAlertButton<Button>]

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
