//  CalendarRepository+Mock.swift
//  Presentation
//
//  Created by 송민교 on 5/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

public extension CalendarRepository {
    static let mock = CalendarRepository(
        fetchMonthRecords: { year, month in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let base = Calendar.current.date(
                from: DateComponents(year: year, month: month, day: 1)
            ) ?? Date()
            return (1 ... 15).compactMap { day -> CalendarRecord? in
                guard day % 2 != 0,
                      let date = Calendar.current.date(byAdding: .day, value: day - 1, to: base),
                      let url = URL(string: "https://picsum.photos/seed/\(day)/200")
                else { return nil }
                return CalendarRecord(
                    dateString: formatter.string(from: date),
                    date: date,
                    imageURL: url
                )
            }
        },
        fetchDayDetail: { date in
            DayDetail(date: date)
        }
    )
}
