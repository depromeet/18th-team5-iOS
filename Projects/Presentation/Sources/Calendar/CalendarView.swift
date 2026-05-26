//
//  CalendarView.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width - Constants.calendarHorizontalSpacing * 2
            let dateCellWidth = (containerWidth - Constants.dateCellHorizontalSpacing * 6) / 7

            VStack(spacing: 0) {
                headerView

                UIBridge<PagingTableView<SolarTermGroup, TermSectionView>>(
                    state: store.calendarState,
                    actionHandler: { action in
                        switch action {
                        case let .anchoredItemChanged(id):
                            store.send(.anchoredItemChanged(id: id))
                        case let .reachedToEnd(direction):
                            store.send(.calendarReachToEnd(direction))
                        }
                    },
                    arguments: .init(
                        defaultAnchorInset: Constants.termSectionHeaderHeight,
                        cellBuilder: {
                            TermSectionView(termGroup: $0, dateCellWidth: dateCellWidth) { id, inset in
                                store.send(.dateCellTapped(dateId: id, inset: inset))
                            }
                        },
                        cellHeightProvider: termSectionViewHeight
                    )
                )
                .padding(.horizontal, Constants.calendarHorizontalSpacing)
                .overlay {
                    if let detail = store.calendarDetail {
                        calendarDetailView(detail)
                            .padding(.top, Constants.detailViewTopPadding)
                            .transition(.move(edge: .bottom))
                    }
                }
                .animation(
                    .easeInOut(duration: 0.35),
                    value: store.calendarDetail
                )
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension CalendarView {
    var headerView: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(store.header?.termTitleText ?? "-")
                    .font(.title2Semibold)
                    .foregroundStyle(Color.gray900)

                Text(store.header?.termRangeText ?? "-")
                    .font(.caption1Medium)
                    .foregroundStyle(Color.gray400)

                Spacer()
            }
            WeekdayLabelRow()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .foregroundStyle(Color.blackAlpha200)
                .frame(height: 1)
        }
    }
}

extension CalendarView {
    func termSectionViewHeight(_ term: SolarTermGroup) -> CGFloat {
        let header = Constants.termSectionHeaderHeight

        let weekCount = term.cells.count
        let monthCellHeight = Constants.monthCellHeight + Constants.dateMonthCellSpacing
        let weekSectionHeight = Constants.dateCellHeight + monthCellHeight
        let weekSpacing = Constants.weekSectionVerticalSpacing * CGFloat(weekCount - 1)
        let calendar = weekSectionHeight * CGFloat(weekCount) + weekSpacing

        let bottom = Constants.termSectionBottomPadding
        return header + calendar + bottom
    }
}

// MARK: TermSectionView

struct TermSectionView: View {
    let termGroup: SolarTermGroup
    let dateCellWidth: CGFloat
    let onDateCellTapped: (SolarTermDate.ID, CGFloat) -> Void

    var body: some View {
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
}

extension TermSectionView {
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
        VStack(alignment: .leading, spacing: Constants.weekSectionVerticalSpacing) {
            ForEach(termDates.indices, id: \.self) { weekIndex in
                HStack(spacing: Constants.dateCellHorizontalSpacing) {
                    ForEach(termDates[weekIndex]) { date in
                        dateCellView(
                            date: date,
                            cellWidth: dateCellWidth,
                            anchorInset: dateCellAnchorPoint(weekIndex: weekIndex)
                        )
                    }
                }
            }
        }
    }

    func dateCellView(date: SolarTermGroupCell, cellWidth: CGFloat, anchorInset: CGFloat) -> some View {
        VStack(spacing: Constants.dateMonthCellSpacing) {
            switch date {
            case .emptyCell:
                Color.clear
                    .frame(width: cellWidth, height: 1)

            case let .dateCell(date):
                VStack(spacing: Constants.dateMonthCellSpacing) {
                    if date.isFirstDayOfMonth {
                        monthCell(date.monthText, cellWidth)
                    } else {
                        Color.clear
                            .frame(
                                width: cellWidth,
                                height: Constants.monthCellHeight
                            )
                    }

                    dateCell(date, cellWidth, anchorInset: anchorInset)
                }
            }
        }
    }

    func monthCell(_ text: String, _ cellWidth: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(Color.gray50)
            .overlay {
                Text(text)
                    .font(.caption2Medium)
                    .foregroundStyle(Color.gray900)
            }
            .frame(width: cellWidth, height: Constants.monthCellHeight)
    }

    func dateCell(_ date: SolarTermDate, _ cellWidth: CGFloat, anchorInset: CGFloat) -> some View {
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
                        // TODO: 색상 수정 예정 -@준영
                        date.isSelected ? Color.white : (date.isToday ? Color(hex: 0x43DA87) : Color.gray900)
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
                .foregroundStyle(
                    date.isSelected
                        ? Color(hex: 0x43DA87)
                        : Color(hex: 0xF7F8F9)
                )
        }
        .onTapGesture {
            onDateCellTapped(date.id, anchorInset)
        }
    }

    func dateCellAnchorPoint(weekIndex: Int) -> CGFloat {
        let weekHeight = Constants.monthCellHeight + Constants.dateMonthCellSpacing + Constants.dateCellHeight
        let weekStartY = CGFloat(weekIndex) * (weekHeight + Constants.weekSectionVerticalSpacing)
        return Constants.termSectionHeaderHeight + weekStartY + Constants.monthCellHeight + Constants
            .dateMonthCellSpacing - Constants.dateCellAnchorOffset
    }
}

// MARK: DetailView

extension CalendarView {
    func calendarDetailView(_ detail: CalendarDetail) -> some View {
        GeometryReader { _ in
            ZStack {
                Color.white
                    .overlay {
                        VStack {
                            LinearGradient(
                                colors: [
                                    .black.opacity(0.05),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 30)
                            Spacer()
                        }
                    }

                VStack {
                    CardStackView(
                        topCardIndex: $store.topMostDetailCardIndex,
                        items: detail.cards
                    ) { index, card in
                        let isTopMost = index == store.topMostDetailCardIndex
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(isTopMost ? Color.gray100 : Color.gray300)
                            .frame(width: 311, height: 400)
                            .overlay {
                                Text(card.name)
                            }
                    }
                    .padding(.top, 20)
                    Spacer()
                }

                // TODO: 디자인 시스템 반영 -@준영
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Button {
                            store.send(.detailOkButtonTapped)
                        } label: {
                            HStack {
                                Spacer()
                                Text("확인")
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .frame(height: 56)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                            }
                        }

                        Button {
                            store.send(.detailOkButtonTapped)
                        } label: {
                            HStack {
                                Spacer()
                                Text("확인")
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .frame(height: 56)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
                .padding(.bottom, 64)
            }
        }
    }
}

private enum Constants {
    static let calendarHorizontalSpacing: CGFloat = 19.5
    static let termSectionHeaderHeight: CGFloat = 46
    static let termSectionBottomPadding: CGFloat = 24
    static let weekSectionVerticalSpacing: CGFloat = 6

    static let monthCellHeight: CGFloat = 20
    static let dateMonthCellSpacing: CGFloat = 2
    static let dateCellHorizontalSpacing: CGFloat = 7
    static let dateCellHeight: CGFloat = 70
    static let dateCellAnchorOffset: CGFloat = 11

    static let detailViewTopPadding: CGFloat = 86
}
