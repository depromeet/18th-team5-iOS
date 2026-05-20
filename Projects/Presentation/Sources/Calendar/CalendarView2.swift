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

    func termSectionViewHeight(_ term: SolarTermGroup) -> CGFloat {
        let weekCount = term.cells.count
        let weekSectionHeight = Constants.dateCellHeight + 22
        let header = Constants.termSectionHeaderHeight
        let calendar = weekSectionHeight * CGFloat(weekCount)
        let bottom = Constants.termSectionBottomPadding
        return header + calendar + bottom
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
                Rectangle().frame(height: 1)
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

            case let .dateCell(info):
                Color.clear
                    .frame(width: cellWidth, height: 20)
                    .overlay {
                        if info.isFirstDayOfMonth {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(Color.gray50)
                                .overlay {
                                    Text(info.monthText)
                                        .font(.caption2Medium)
                                        .foregroundStyle(Color.gray900)
                                }
                        }
                    }

                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.gray)
                    .frame(
                        width: cellWidth,
                        height: Constants.dateCellHeight
                    )
                    .overlay {
                        Text(info.dayText)
                    }
            }
        }
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
