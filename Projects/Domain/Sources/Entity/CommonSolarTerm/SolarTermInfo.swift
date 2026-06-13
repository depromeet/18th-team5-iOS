//
//  SolarTermInfo.swift
//  Domain
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Core
import Foundation

public struct SolarTermInfo: Equatable {
    public let year: SolarTermYear
    public let term: SolarTerm
    public let startDate: Date
    public let endDate: Date

    public init(
        year: SolarTermYear,
        term: SolarTerm,
        startDate: Date,
        endDate: Date
    ) {
        self.year = year
        self.term = term
        self.startDate = startDate
        self.endDate = endDate
    }

    public var dateRange: Range<Date> {
        startDate ..< endDate
    }

    public var formattedDateRange: String {
        let lastDay = endDate.previousDay
        let start = startDate.string(.shortMonthDayDot)
        let end = lastDay.string(.shortMonthDayDot)
        return "\(start) - \(end)"
    }

    public var formattedFullDateRange: String {
        let lastDay = endDate.previousDay
        let start = startDate.string(.monthDayKorean)
        let end = lastDay.string(.monthDayKorean)

        if startDate.year == lastDay.year {
            return "\(startDate.year)년 \(start) - \(end)"
        } else {
            return "\(startDate.year)년 \(start) - \(lastDay.year)년 \(end)"
        }
    }
}
