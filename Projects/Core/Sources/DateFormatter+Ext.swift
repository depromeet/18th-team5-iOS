//
//  DateFormatter+Ext.swift
//  Core
//
//  Created by 송민교 on 5/20/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public extension DateFormatter {
    static let monthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter
    }()

    static let monthDayKorean: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter
    }()
}
