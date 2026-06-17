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
    public static let serverTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return formatter
    }()

    private static func makeFormatter(_ dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = dateFormat
        return formatter
    }
}
