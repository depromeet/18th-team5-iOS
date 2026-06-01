//
//  CalendarSolarTerm.swift
//  Domain
//
//  Created by choijunios on 6/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct CalendarSolarTermsResponse {
    public let fetchedSolarTerms: [CalendarSolarTerm]
    public let prevSolarTerm: CalendarSolarTerm?
    public let nextSolarTerm: CalendarSolarTerm?

    public init(
        fetchedSolarTerms: [CalendarSolarTerm],
        prevSolarTerm: CalendarSolarTerm?,
        nextSolarTerm: CalendarSolarTerm?
    ) {
        self.fetchedSolarTerms = fetchedSolarTerms
        self.prevSolarTerm = prevSolarTerm
        self.nextSolarTerm = nextSolarTerm
    }
}

public struct CalendarSolarTerm: Equatable {
    public let solarTermId: Int
    public let term: SolarTerm
    public let year: SolarTermYear
    public let dates: [CalendarSolarTermDate]

    public init(
        solarTermId: Int,
        term: SolarTerm,
        year: SolarTermYear,
        dates: [CalendarSolarTermDate]
    ) {
        self.solarTermId = solarTermId
        self.term = term
        self.year = year
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
