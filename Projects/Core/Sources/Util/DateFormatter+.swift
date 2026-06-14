//
//  DateFormatter+.swift
//  Core
//
//  Created by 이정원 on 6/10/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

extension DateFormatter {
    public static let yearMonthDayDash = makeFormatter("yyyy-MM-dd")
    public static let shortYearMonthDayDot = makeFormatter("yy.MM.dd")
    public static let shortMonthDayDot = makeFormatter("MM.dd")
    public static let monthDayKorean = makeFormatter("M월 d일")

    private static func makeFormatter(_ dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = dateFormat
        return formatter
    }
}
