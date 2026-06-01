//
//  CalendarTermData.swift
//  Presentation
//
//  Created by choijunios on 6/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

public struct CalendarTermData: Equatable {
    let requestId: Int
    var isInflight: Bool
    var data: CalendarSolarTerm?
}
