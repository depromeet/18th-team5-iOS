//  CalendarView.swift
//  Presentation
//
//  Created by 송민교 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>

    public init(store: StoreOf<CalendarFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 12) {
            CalendarHeaderView(
                title: store.currentMonth.yearMonthString,
                onPrevious: { store.send(.previousMonthTap) },
                onNext: { store.send(.nextMonthTap) }
            )

            WeekdayLabelRow()

            CalendarGridView(
                weeks: store.currentMonth.calendarWeeks,
                dailyRecords: store.dailyRecords,
                selectedDate: store.selectedDate,
                onDayTap: { store.send(.dayTap($0)) }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .onAppear { store.send(.onAppear) }
        .sheet(
            item: $store.scope(state: \.dayDetail, action: \.dayDetail)
        ) { detailStore in
            DayDetailView(store: detailStore)
        }
    }
}

// MARK: - CalendarGridView

struct CalendarGridView: View {
    let weeks: [[Date?]]
    let dailyRecords: [DateComponents: CalendarRecord]
    let selectedDate: Date?
    let onDayTap: (Date) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                HStack(spacing: 0) {
                    ForEach(0 ..< 7) { dayIndex in
                        if let date = weeks[weekIndex][dayIndex] {
                            let key = Calendar.current.dateComponents([.year, .month, .day], from: date)
                            let record = dailyRecords[key]
                            let isSelected = selectedDate.map {
                                Calendar.current.isDate($0, inSameDayAs: date)
                            } ?? false

                            DayCell(
                                day: Calendar.current.component(.day, from: date),
                                imageURL: record?.imageURL,
                                isSelected: isSelected,
                                onTap: record != nil ? { onDayTap(date) } : nil
                            )
                            .frame(maxWidth: .infinity)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView(
        store: .init(initialState: .init()) {
            CalendarFeature()
        } withDependencies: {
            $0.calendarRepository = .mock
        }
    )
}

// MARK: - Date Helpers

private extension Date {
    var calendarWeeks: [[Date?]] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay)
        else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay)
        let offset = (weekday - 2 + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return stride(from: 0, to: days.count, by: 7).map { Array(days[$0 ..< $0 + 7]) }
    }
}
