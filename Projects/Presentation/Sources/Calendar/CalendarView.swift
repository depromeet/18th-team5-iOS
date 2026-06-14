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
    @State var isFloatingRecordButtonExpanded: Bool = true

    var body: some View {
        GeometryReader { geo in
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
                        case let .cellDidDisappear(id):
                            store.send(.calendarTermDidDisappear(id: id))
                        case let .cellWillAppear(id):
                            store.send(.calendarTermWillAppear(id: id))
                        case .willBeginDragging:
                            guard isFloatingRecordButtonExpanded else { return }
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                isFloatingRecordButtonExpanded = false
                            }
                        }
                    },
                    arguments: .init(
                        defaultAnchorInset: Constants.termSectionHeaderHeight,
                        bottomPadding: Constants.tableBottomPadding,
                        cellBuilder: {
                            termSectionView(
                                termGroup: $0,
                                dateCellWidth: cellWidth(screenWidth: geo.size.width)
                            )
                            .eraseView()
                        },
                        cellHeightProvider: termSectionViewHeight
                    )
                )
                .padding(.horizontal, Constants.calendarHorizontalSpacing)
                .onGeometryChange(
                    for: CGFloat.self,
                    of: { $0.size.height - $0.safeAreaInsets.bottom }
                ) { height in
                    let cellHeight = CalendarDateCell.Constants.cellHeight
                    sheetHeight = height - cellHeight - 12
                }
                .ignoresSafeArea(.container, edges: [.bottom])
                .overlay(alignment: .top) {
                    if let presents = store.presentMoveToCurrentTermButton, !store.isDetailViewPresenting {
                        let style: WeakFloatingButton.Style = switch presents {
                        case .up: .up
                        case .down: .down
                        }
                        WeakFloatingButton(style: style) {
                            store.send(.moveToCurrentTermButtonTapped)
                        }
                        .padding(.top, 16)
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: store.presentMoveToCurrentTermButton)
                .overlay {
                    if let detailStore = store.scope(state: \.detail, action: \.detail.presented) {
                        CalendarDetailView(store: detailStore)
                            .transition(.move(edge: .bottom))
                            .padding(.top, Constants.detailViewTopPadding)
                            .onDisappear {
                                store.send(.detailViewDisappeared)
                            }
                            .id(detailStore.id)
                    }
                }
                .animation(.easeInOut, value: store.detail != nil)
            }
            .overlay(alignment: .bottomTrailing) {
                if !store.isDetailViewPresenting {
                    floatingRecordButton
                        .padding(.trailing, Constants.floatingButtonTrailingPadding)
                        .padding(.bottom, Constants.floatingButtonBottomPadding)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            isFloatingRecordButtonExpanded = true
            store.send(.onAppear)
        }
        .customAlert(store.scope(state: \.alert, action: \.alert))
    }
}

// MARK: Floating Record Button

private extension CalendarView {
    var floatingRecordButton: some View {
        Button {
            store.send(.floatingRecordButtonTapped)
        } label: {
            HStack(spacing: 4) {
                Image.icPlus
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.monoWhite)
                    .frame(width: 24, height: 24)

                if isFloatingRecordButtonExpanded {
                    Text("기록하기")
                        .font(.body1Semibold)
                        .foregroundStyle(Color.monoWhite)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, isFloatingRecordButtonExpanded ? 20 : 16)
            .frame(height: Constants.floatingButtonSize)
            .frame(minWidth: Constants.floatingButtonSize)
            .background {
                EllipticalGradient.buttonBackground
                    .background(Color.gray700)
            }
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

extension CalendarView {
    var headerView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                if store.detail != nil {
                    Button {
                        store.send(.headerBackButtonTapped)
                    } label: {
                        Image.icArrowBack
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.gray800)
                            .frame(width: 24, height: 24)
                            .transition(.opacity)
                    }
                }

                HStack(alignment: .center, spacing: 8) {
                    Text(store.header?.termTitleText ?? "-")
                        .font(.title2Semibold)
                        .foregroundStyle(Color.gray900)

                    Text(store.header?.termRangeText ?? "-")
                        .font(.caption1Medium)
                        .foregroundStyle(Color.gray600)

                    Spacer()
                }
            }
            .animation(.easeInOut, value: store.detail != nil)

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

// MARK: Calc

extension CalendarView {
    func termSectionViewHeight(_ term: SolarTermGroup) -> CGFloat {
        let header = Constants.termSectionHeaderHeight

        let weekCount = term.cells.count
        let weekSectionHeight = CalendarDateCell.Constants.cellHeight
        let weekSpacing = Constants.weekSectionVerticalSpacing * CGFloat(weekCount - 1)
        let calendar = weekSectionHeight * CGFloat(weekCount) + weekSpacing

        let bottom = Constants.termSectionBottomPadding
        return header + calendar + bottom
    }

    func cellWidth(screenWidth: CGFloat) -> CGFloat {
        let containerWidth = screenWidth - Constants.calendarHorizontalSpacing * 2
        return (containerWidth - Constants.dateCellHorizontalSpacing * 6) / 7
    }
}

// MARK: TermSectionView

extension CalendarView {
    func termSectionView(termGroup: SolarTermGroup, dateCellWidth: CGFloat) -> some View {
        VStack(spacing: .zero) {
            termSectionHeaderView(termGroup)
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

    func termSectionHeaderView(_ termGroup: SolarTermGroup) -> some View {
        VStack {
            HStack {
                Text(termGroup.termText)
                    .font(.headline2Medium)
                    .foregroundStyle(
                        termGroup.containsToday ? Color.green600 : Color.gray900
                    )
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
            CalendarDateCell(
                date: date,
                data: store.state.dateData(date)
            ) {
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
    static let tableBottomPadding: CGFloat = 300

    static let dateCellHorizontalSpacing: CGFloat = 7
    static let dateCellAnchorOffset: CGFloat = 11
    static let floatingButtonSize: CGFloat = 56
    static let floatingButtonTrailingPadding: CGFloat = 20
    static let floatingButtonBottomPadding: CGFloat = 84

    static var detailViewTopPadding: CGFloat {
        CalendarDateCell.Constants.cellHeight + 12
    }
}

private extension View {
    func eraseView() -> AnyView {
        AnyView(self)
    }
}
