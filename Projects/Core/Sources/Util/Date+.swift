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

// MARK: - Date Format

public enum DateFormat: String {
    case shortYearMonthDayDot = "yy.MM.dd"
    case shortMonthDayDot = "MM.dd"
    case monthDayKorean = "M월 d일"
}

public extension Date {
    func string(_ dateFormat: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: self)
    }

    var relativeTimeString: String {
        let timeInterval = Date.now.timeIntervalSince(self)
        let absoluteTimeInterval = abs(timeInterval)

        guard absoluteTimeInterval >= 60 else { return "지금" }
        let suffix = timeInterval >= 0 ? "전" : "후"

        if absoluteTimeInterval < 60 * 60 {
            let minutes = Int(absoluteTimeInterval / 60)
            return "\(minutes)분 \(suffix)"
        } else {
            let hours = Int(absoluteTimeInterval / (60 * 60))
            return "\(hours)시간 \(suffix)"
        }
    }
}
