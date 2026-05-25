//
//  Date+Formatting.swift
//  Presentation
//
//  Created by 송민교 on 5/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//
import Foundation

extension Date {
    private static let yearMonthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f
    }()

    var yearMonthString: String {
        Self.yearMonthFormatter.string(from: self)
    }
}
