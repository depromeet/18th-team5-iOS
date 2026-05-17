//
//  SolarTermInfo.swift
//  Domain
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

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
}
