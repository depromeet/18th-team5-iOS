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

// MARK: - CalendarHeaderView

struct CalendarHeaderView: View {
    let title: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.body2, \.semiBold)
                    .foregroundStyle(Color.gray500)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: onPrevious) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 13)
                            .foregroundStyle(Color.gray900)
                    }
                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 13)
                            .foregroundStyle(Color.gray900)
                    }
                }
            }
            .padding(.bottom, 12)

            Divider()
                .foregroundStyle(Color.gray100)
        }
    }
}

// MARK: - WeekdayLabelRow

struct WeekdayLabelRow: View {
    private let labels = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.caption2, \.regular)
                    .foregroundStyle(Color.gray400)
                    .frame(maxWidth: .infinity)
            }
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
                                date: date,
                                record: record,
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

// MARK: - DayCell

struct DayCell: View {
    let date: Date
    let record: CalendarRecord?
    let isSelected: Bool
    let onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption1, \.regular)
                .foregroundStyle(isSelected ? Color.monoWhite : Color.gray900)

            DayPhotoView(record: record, isSelected: isSelected)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(isSelected ? Color.gray900 : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - DayPhotoView

struct DayPhotoView: View {
    let record: CalendarRecord?
    let isSelected: Bool

    var body: some View {
        Group {
            if let record {
                AsyncImage(url: record.imageURL) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color.gray100
                    }
                }
                .frame(width: 34, height: 34)
                .clipShape(CalendarPhotoShape())
            } else {
                Color.clear
                    .frame(width: 34, height: 34)
            }
        }
    }
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
