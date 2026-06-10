//
//  Date+.swift
//  Core
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public extension Date {
    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
}
