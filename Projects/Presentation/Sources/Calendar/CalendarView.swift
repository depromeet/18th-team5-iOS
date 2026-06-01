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

    @State var sheetHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width - Constants.calendarHorizontalSpacing * 2
            let dateCellWidth = (containerWidth - Constants.dateCellHorizontalSpacing * 6) / 7

            VStack(spacing: 0) {
                headerView

                UIBridge<PagingTableView<SolarTermGroup>>(
                    state: store.calendarState,
                    actionHandler: { action in
                        switch action {
                        case let .anchoredItemChanged(id):
                            store.send(.anchoredTermChanged(id: id))
                        case let .reachedToEnd(direction):
                            store.send(.calendarReachToEnd(direction))
                        }
                    },
                    arguments: .init(
                        defaultAnchorInset: Constants.termSectionHeaderHeight,
                        cellBuilder: {
                            termSectionView(
                                termGroup: $0,
                                dateCellWidth: dateCellWidth
                            )
                            .eraseView()
                        },
                        cellHeightProvider: termSectionViewHeight
                    )
                )
                .padding(.horizontal, Constants.calendarHorizontalSpacing)
                .background {
                    GeometryReader {
                        Color.clear
                            .onChange(of: $0.size) { _, size in
                                let calendarHeight = size.height - bottomSafeInset
                                let cellHeight = CalendarDateCell.Constants.cellHeight
                                sheetHeight = calendarHeight - cellHeight - 12
                            }
                    }
                }
            }
        }
        .ignoresSafeArea(.container, edges: [.bottom])
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(item: $store.calendarDetail) {
            calendarDetailView($0)
                .presentationBackgroundInteraction(.enabled)
                .presentationDetents([.height(sheetHeight)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
                .interactiveDismissDisabled()
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
        let weekSectionHeight = CalendarDateCell.Constants.cellHeight
        let weekSpacing = Constants.weekSectionVerticalSpacing * CGFloat(weekCount - 1)
        let calendar = weekSectionHeight * CGFloat(weekCount) + weekSpacing

        let bottom = Constants.termSectionBottomPadding

        print("\(term.solarTermInfo.term.koreanName): \(header + calendar + bottom)")

        return header + calendar + bottom
    }
}

// MARK: TermSectionView

extension CalendarView {
    func termSectionView(termGroup: SolarTermGroup, dateCellWidth: CGFloat) -> some View {
        VStack(spacing: .zero) {
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
            .padding(.top, 24)

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

    @ViewBuilder
    func dateCellView(date: SolarTermGroupCell, cellWidth: CGFloat, anchorInset: CGFloat) -> some View {
        switch date {
        case .emptyCell:
            Color.clear
                .frame(width: cellWidth, height: 1)

        case let .dateCell(date):
            CalendarDateCell(date: date) {
                store.send(.dateCellTapped(dateId: date.id, inset: anchorInset))
            }
            .frame(width: cellWidth)
        }
    }

    func dateCellAnchorPoint(weekIndex: Int) -> CGFloat {
        let weekHeight = CalendarDateCell.Constants.cellHeight
        let weekSpacing = Constants.weekSectionVerticalSpacing
        let weekStartY = (weekHeight + weekSpacing) * CGFloat(weekIndex)
        return Constants.termSectionHeaderHeight + weekStartY
    }
}

// MARK: DetailView

extension CalendarView {
    func calendarDetailView(_ detail: CalendarDetail) -> some View {
        GeometryReader { _ in
            ZStack {
                detailViewBackgroundView

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

                detailViewBottomView
            }
        }
    }

    var detailViewBackgroundView: some View {
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
    }

    var detailViewBottomView: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Button {
                    // TODO: 수정
                    store.send(.detailOkButtonTapped)
                } label: {
                    Text("이미지 저장")
                }
                .buttonStyle(.master(.large))

                Button {
                    // TODO: 수정
                    store.send(.detailOkButtonTapped)
                } label: {
                    Text("이미지 공유")
                }
                .buttonStyle(.master(.large))
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
}

private extension CalendarView {
    var bottomSafeInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .safeAreaInsets.bottom ?? 0
    }
}

private enum Constants {
    static let calendarHorizontalSpacing: CGFloat = 19.5
    static let termSectionHeaderHeight: CGFloat = 56
    static let termSectionBottomPadding: CGFloat = 12
    static let weekSectionVerticalSpacing: CGFloat = 4

    static let dateCellHorizontalSpacing: CGFloat = 7
    static let dateCellAnchorOffset: CGFloat = 11

    static var detailViewTopPadding: CGFloat {
        CalendarDateCell.Constants.cellHeight + 12
    }
}

private extension View {
    func eraseView() -> AnyView { AnyView(self) }
}
