//
//  CalendarSolarTerm.swift
//  Domain
//
//  Created by choijunios on 6/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct CalendarSolarTermsResponse {
    public let solarTerms: [CalendarSolarTerm]
    public let prevSolarTermId: Int?
    public let nextSolarTermId: Int?

    public init(
        solarTerms: [CalendarSolarTerm],
        prevSolarTermId: Int?,
        nextSolarTermId: Int?
    ) {
        self.solarTerms = solarTerms
        self.prevSolarTermId = prevSolarTermId
        self.nextSolarTermId = nextSolarTermId
    }
}

public struct CalendarSolarTerm: Equatable {
    public let solarTermId: Int
    public let solarTermInfo: SolarTermInfo
    public let dates: [CalendarSolarTermDate]

    public init(
        solarTermId: Int,
        solarTermInfo: SolarTermInfo,
        dates: [CalendarSolarTermDate]
    ) {
        self.solarTermId = solarTermId
        self.solarTermInfo = solarTermInfo
        self.dates = dates
    }
}

public struct CalendarSolarTermDate: Equatable {
    public let date: Date
    public let thumbnailURL: URL?

    public init(date: Date, thumbnailURL: URL?) {
        self.date = date
        self.thumbnailURL = thumbnailURL
    }
}
