//
//  SolarTermResponseDTO.swift
//  Data
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct SolarTermFileDTO: Decodable {
    let year: Int
    let terms: [SolarTermEntryDTO]
}

struct SolarTermEntryDTO: Decodable {
    let id: String
    let month: Int
    let day: Int
}

// MARK: - Domain Mapping

extension SolarTermFileDTO {
    func toDomain() -> [SolarTermInfo] {
        let calendar = Calendar(identifier: .gregorian)
        guard let timezone = TimeZone(identifier: "Asia/Seoul") else { return [] }

        var infos: [SolarTermInfo] = []

        for (index, entry) in terms.enumerated() {
            guard let term = SolarTerm.fromID(entry.id),
                  let startDate = Self.makeDate(year, entry.month, entry.day, calendar, timezone)
            else { continue }

            let endDate: Date
            if index + 1 < terms.count {
                let next = terms[index + 1]
                guard let nextDate = Self.makeDate(year, next.month, next.day, calendar, timezone)
                else { continue }
                endDate = nextDate
            } else {
                guard let yearEnd = Self.makeEndOfYear(year, calendar, timezone)
                else { continue }
                endDate = yearEnd
            }

            infos.append(SolarTermInfo(term: term, startDate: startDate, endDate: endDate))
        }

        return infos
    }

    private static func makeDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ calendar: Calendar,
        _ timezone: TimeZone
    ) -> Date? {
        let components = DateComponents(
            calendar: calendar,
            timeZone: timezone,
            year: year,
            month: month,
            day: day
        )
        return calendar.date(from: components)
    }

    private static func makeEndOfYear(
        _ year: Int,
        _ calendar: Calendar,
        _ timezone: TimeZone
    ) -> Date? {
        let components = DateComponents(
            calendar: calendar,
            timeZone: timezone,
            year: year,
            month: 12,
            day: 31,
            hour: 23,
            minute: 59,
            second: 59
        )
        return calendar.date(from: components)
    }
}

// MARK: - SolarTerm ID Mapping

private extension SolarTerm {
    static func fromID(_ id: String) -> SolarTerm? {
        allCases.first { String(describing: $0) == id }
    }
}
