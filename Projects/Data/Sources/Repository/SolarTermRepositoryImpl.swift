//
//  SolarTermRepositoryImpl.swift
//  Data
//
//  Created by choijunios on 5/17/26.
//
// Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension SolarTermRepository: @retroactive DependencyKey {
    public static let liveValue: SolarTermRepository = SolarTermRepositoryImpl.live()
}

public enum SolarTermRepositoryImpl {
    public static func live() -> SolarTermRepository {
        SolarTermRepository(
            fetchSolarTerms: { year in
                guard let url = Bundle.module.url(
                    forResource: "solar_term_\(year.rawValue)",
                    withExtension: "json"
                )
                else {
                    throw DomainError.notFound
                }

                let data = try Data(contentsOf: url)
                let dto = try JSONDecoder().decode(SolarTermFileDTO.self, from: data)
                return dto.toDomain()
            }
        )
    }
}

// MARK: - Domain Mapping

extension SolarTermFileDTO {
    func toDomain() -> [SolarTermInfo] {
        let calendar = Calendar(identifier: .gregorian)
        guard let timezone = TimeZone(identifier: "Asia/Seoul") else { return [] }

        let sortedTerms = terms.sorted { lhs, rhs in
            if lhs.month != rhs.month { return lhs.month < rhs.month }
            return lhs.day < rhs.day
        }
        var infos: [SolarTermInfo] = []

        for (index, entry) in sortedTerms.enumerated() {
            guard let term = SolarTerm(rawValue: entry.id),
                  let startDate = Self.makeDate(year, entry.month, entry.day, calendar, timezone)
            else { continue }

            var endDate: Date?
            if index + 1 < sortedTerms.count {
                let nextTerm = sortedTerms[index + 1]
                guard let nextTermStartDate = Self.makeDate(year, nextTerm.month, nextTerm.day, calendar, timezone)
                else { continue }

                endDate = nextTermStartDate
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
