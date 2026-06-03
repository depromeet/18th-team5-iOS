//
//  CalendarFeature+Mapping.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

// MARK: - 맵핑(Domain > Presentation)

extension CalendarFeature {
    func mapToHeader(_ term: SolarTermGroup) -> CalendarHeader {
        let info = term.solarTermInfo
        let startDayText = Self.termDateFormatter.string(from: info.startDate)
        let termLastDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: info.endDate
        ) ?? info.endDate
        let lastDayText = Self.termDateFormatter.string(from: termLastDate)
        return CalendarHeader(
            termTitleText: term.termText,
            termRangeText: "\(startDayText)~\(lastDayText)"
        )
    }

    func mapToYearGroup(now: Date, year: SolarTermYear, terms: [SolarTermInfo]) -> Page<SolarTermGroup> {
        Page(
            id: year.rawValue,
            items: terms.map { mapToTermGroup(now, $0) }
        )
    }

    func mapToTermGroup(_ now: Date, _ termInfo: SolarTermInfo) -> SolarTermGroup {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekday = calendar.component(.weekday, from: termInfo.startDate)
        let offset = (weekday - 2 + 7) % 7

        var cells: [SolarTermGroupCell] = []
        for index in 0 ..< offset {
            cells.append(.emptyCell(
                id: "\(termInfo.year.rawValue)_\(termInfo.term.rawValue)_emptycell_\(index)"
            ))
        }

        var containsToday = false
        for date in termInfo.termDates {
            guard let ymd = yearMonthDay(date),
                  let todayYmd = yearMonthDay(now)
            else { continue }

            if !containsToday {
                containsToday = (ymd == todayYmd)
            }
            cells.append(
                .dateCell(
                    SolarTermDate(
                        id: Self.dateIdFormatter.string(from: date),
                        monthText: "\(ymd.month)월",
                        dayText: String(ymd.day),
                        isFirstDayOfMonth: ymd.day == 1,
                        isToday: ymd == todayYmd,
                        isSelected: false,
                        year: termInfo.year,
                        term: termInfo.term,
                        month: ymd.month,
                        day: ymd.day
                    )
                )
            )
        }
        return SolarTermGroup(
            id: Self.termGroupId(year: termInfo.year, term: termInfo.term),
            termText: termInfo.term.koreanName,
            containsToday: containsToday,
            solarTermInfo: termInfo,
            cells: cells.chunked(size: 7)
        )
    }

    func yearMonthDay(_ date: Date) -> (year: Int, month: Int, day: Int)? {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day
        else { return nil }
        return (year, month, day)
    }

    static let termDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM.dd"
        return df
    }()

    static let dayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df
    }()

    static let dateIdFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}

// MARK: - SolarTermInfo 확장

private extension SolarTermInfo {
    var termDates: [Date] {
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)

        var dates: [Date] = [start]
        guard var next = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
            return dates
        }
        while next < end {
            dates.append(next)
            guard let subsequent = Calendar.current.date(byAdding: .day, value: 1, to: next) else { break }
            next = subsequent
        }
        return dates
    }
}

private extension Array {
    func chunked(size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
