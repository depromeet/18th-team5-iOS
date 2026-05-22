//
//  CalendarView2.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct CalendarView2: View {
    @Bindable var store: StoreOf<CalendarFeature2>

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width - Constants.calendarHorizontalSpacing * 2
            let dateCellWidth = (containerWidth - Constants.dateCellHorizontalSpacing * 6) / 7
            VStack(spacing: 0) {
                headerView

                PagingTableView(
                    groups: store.yearPages,
                    centerItemId: $store.centerItemId,
                    onPagingRequest: { store.send(.calendarPagingRequest($0)) },
                    cellHeight: { termSectionViewHeight($0) },
                    cellContent: { termSectionView($0, dateCellWidth: dateCellWidth) }
                )
                .padding(.horizontal, Constants.calendarHorizontalSpacing)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension CalendarView2 {
    var headerView: some View {
        VStack {
            HStack(alignment: .center, spacing: 8) {
                Text(store.header.termTitleText)
                    .font(.title2Semibold)
                    .foregroundStyle(Color.gray900)

                Text(store.header.termRangeText)
                    .font(.caption1Medium)
                    .foregroundStyle(Color.gray400)

                Spacer()
            }
            WeekdayLabelRow()
        }
        .padding(.horizontal, 19.5)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
}

extension CalendarView2 {
    func termSectionView(_ termGroup: SolarTermGroup, dateCellWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            termSectionHeaderView(termGroup.termText)
            termCalendarView(termGroup.cells, dateCellWidth: dateCellWidth)
        }
        .padding(.bottom, Constants.termSectionBottomPadding)
        .overlay {
            VStack {
                Spacer()
                Rectangle()
                    .foregroundStyle(Color.gray200)
                    .frame(height: 1)
            }
        }
    }

    func termSectionHeaderView(_ termText: String) -> some View {
        VStack {
            HStack {
                Text(termText)
                    .font(.headline2Medium)
                    .foregroundStyle(Color.gray900)
                Spacer()
            }
            .padding(.top, 12)

            Spacer()
        }
        .frame(height: Constants.termSectionHeaderHeight)
    }

    func termCalendarView(_ termDates: [[SolarTermGroupCell]], dateCellWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: Constants.weakSectionVerticalSpacing) {
            ForEach(termDates.indices, id: \.self) { weekIndex in
                HStack(spacing: Constants.dateCellHorizontalSpacing) {
                    ForEach(termDates[weekIndex]) {
                        dateCellView($0, cellWidth: dateCellWidth)
                    }
                }
            }
        }
    }

    func dateCellView(_ date: SolarTermGroupCell, cellWidth: CGFloat) -> some View {
        VStack(spacing: 2) {
            switch date {
            case .emptyCell:
                Color.clear
                    .frame(
                        width: cellWidth,
                        height: Constants.dateCellHeight
                    )
                    .padding(.top, 20)

            case let .dateCell(date):
                Color.clear
                    .frame(width: cellWidth, height: 20)
                    .overlay {
                        if date.isFirstDayOfMonth {
                            monthCell(date.monthText)
                        }
                    }

                dateCell(date, cellWidth)
            }
        }
    }

    func monthCell(_ text: String) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(Color.gray50)
            .overlay {
                Text(text)
                    .font(.caption2Medium)
                    .foregroundStyle(Color.gray900)
            }
    }

    func dateCell(_ date: SolarTermDate, _ cellWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 5)
            VStack(spacing: 0) {
                // TODO: 이미지로 교체 -@준영
                Rectangle()
                    .foregroundStyle(.gray)
                    .frame(width: 32, height: 32)
                    .clipShape(
                        CalendarCellImageShape(
                            containerPadding: 2.56,
                            containerRadius: 4,
                            protrusionRadius: 1.78
                        )
                    )
                Spacer(minLength: 0)
                Text(date.dayText)
                    .font(.body2Medium)
                    .foregroundStyle(
                        date.isToday ? Color(hex: 0x43DA87) : Color.gray900
                    )
            }
            .padding(.vertical, 6)
            Spacer(minLength: 5)
        }
        .frame(
            width: cellWidth,
            height: Constants.dateCellHeight
        )
        .background {
            RoundedRectangle(cornerRadius: 8)
                // TODO: 디자인 시스템 반영 필요 -@준영
                .foregroundStyle(Color(hex: 0xF7F8F9))
        }
    }
}

extension CalendarView2 {
    func termSectionViewHeight(_ term: SolarTermGroup) -> CGFloat {
        let header = Constants.termSectionHeaderHeight

        let weekCount = term.cells.count
        let weekSectionHeight = Constants.dateCellHeight + 22
        let weekSpacing = Constants.weakSectionVerticalSpacing * CGFloat(weekCount - 1)
        let calendar = weekSectionHeight * CGFloat(weekCount) + weekSpacing

        let bottom = Constants.termSectionBottomPadding
        return header + calendar + bottom
    }
}

private extension CalendarView2 {
    enum Constants {
        static let calendarHorizontalSpacing: CGFloat = 19.5
        static let termSectionHeaderHeight: CGFloat = 46
        static let termSectionBottomPadding: CGFloat = 24
        static let weakSectionVerticalSpacing: CGFloat = 6

        static let dateCellHorizontalSpacing: CGFloat = 7
        static let dateCellHeight: CGFloat = 70
    }
}
