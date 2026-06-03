//
//  CalendarTermRecordsResponse.swift
//  Domain
//
//  Created by choijunios on 6/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct CalendarTermRecordsResponse {
    public let fetchedTermRecords: [CalendarTermRecord]
    public let prevTermEmptyRecord: CalendarTermRecord?
    public let nextTermEmptyRecord: CalendarTermRecord?

    public init(
        fetchedTermRecords: [CalendarTermRecord],
        prevTermEmptyRecord: CalendarTermRecord?,
        nextTermEmptyRecord: CalendarTermRecord?
    ) {
        self.fetchedTermRecords = fetchedTermRecords
        self.prevTermEmptyRecord = prevTermEmptyRecord
        self.nextTermEmptyRecord = nextTermEmptyRecord
    }
}

public struct CalendarTermRecord: Equatable {
    public let solarTermId: Int
    public let term: SolarTerm
    public let year: SolarTermYear
    public let dates: [CalendarDateRecord]

    public init(
        solarTermId: Int,
        term: SolarTerm,
        year: SolarTermYear,
        dates: [CalendarDateRecord]
    ) {
        self.solarTermId = solarTermId
        self.term = term
        self.year = year
        self.dates = dates
    }
}

public struct CalendarDateRecord: Equatable {
    public let date: Date
    public let thumbnailURL: URL?

    public init(date: Date, thumbnailURL: URL?) {
        self.date = date
        self.thumbnailURL = thumbnailURL
    }
}
