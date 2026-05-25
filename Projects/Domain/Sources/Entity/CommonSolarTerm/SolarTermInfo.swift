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
        let start = DateFormatter.monthDay.string(from: startDate)
        let end = DateFormatter.monthDay.string(from: endDate)
        return "\(start) - \(end)"
    }

    public var formattedFullDateRange: String {
        let start = DateFormatter.monthDayKorean.string(from: startDate)
        let end = DateFormatter.monthDayKorean.string(from: endDate)
        let calendar = Calendar(identifier: .gregorian)
        let startYear = calendar.component(.year, from: startDate)
        let endYear = calendar.component(.year, from: endDate)

        if startYear == endYear {
            return "\(startYear)년 \(start) - \(end)"
        } else {
            return "\(startYear)년 \(start) - \(endYear)년 \(end)"
        }
    }
}
