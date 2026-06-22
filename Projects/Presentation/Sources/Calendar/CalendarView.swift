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
            VStack(spacing: 0) {
                headerView

                UIBridge<PagingTableView<SolarTermGroup, TermRecordContext>>(
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
                            store.send(.scrollViewWillBeginDragging)
                        }
                    },
                    arguments: .init(
                        defaultAnchorInset: Constants.termSectionHeaderHeight,
                        bottomPadding: Constants.tableBottomPadding,
                        cellBuilder: { termGroup, context in
                            TermSectionView(
                                termGroup: termGroup,
                                dateCellWidth: cellWidth(screenWidth: geo.size.width),
                                records: termRecords(termGroup, context: context),
                                onDateTap: { dateId, inset in
                                    store.send(.dateCellTapped(dateId: dateId, inset: inset))
                                }
                            )
                        },
                        cellHeightProvider: termSectionViewHeight
                    )
                )
                .padding(.horizontal, Constants.calendarHorizontalSpacing)
                .onGeometryChange(
                    for: CGFloat.self,
                    of: { $0.size.height - $0.safeAreaInsets.bottom }
                ) { height in
                    let cellHeight = CalendarAnchorMetrics.cellHeight
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
                    FloatingRecordButton(
                        isExpanded: $store.isFloatingRecordButtonExpanded
                    ) {
                        store.send(.floatingRecordButtonTapped)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 84)
                    .transition(.opacity)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: store.anchorHapticTrigger)
        .task { store.send(.viewDidLoad) }
        .onAppear {
            store.send(.onAppear)
        }
        .customAlert(store.scope(state: \.alert, action: \.alert))
        .toastContainer()
    }
}

// MARK: Floating Record Button

private struct FloatingRecordButton: View {
    @Binding var isExpanded: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            if isExpanded {
                HStack(spacing: 4) {
                    Image.icPlus
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.monoWhite)
                        .frame(width: 20, height: 20)

                    Text("기록하기")
                        .font(.body1Semibold)
                        .foregroundStyle(Color.monoWhite)
                        .transition(.opacity)
                }
                .frame(height: 56)
                .padding(.trailing, 20)
                .padding(.leading, 16)
                .background {
                    EllipticalGradient.buttonBackground
                        .background(Color.gray700)
                }
                .clipShape(Capsule())
                .contentShape(Capsule())
                .transition(.opacity)
            } else {
                Image.icPlus
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.monoWhite)
                    .frame(width: 20, height: 20)
                    .padding(18)
                    .background {
                        EllipticalGradient.buttonBackground
                            .background(Color.gray700)
                    }
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .transition(.opacity)
            }
        }
        .accessibilityLabel("기록하기")
        .accessibilityHint("선택한 날짜의 기록 화면으로 이동")
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
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
        let weekSectionHeight = CalendarAnchorMetrics.cellHeight
        let weekSpacing = Constants.weekSectionVerticalSpacing * CGFloat(weekCount - 1)
        let calendar = weekSectionHeight * CGFloat(weekCount) + weekSpacing

        let bottom = Constants.termSectionBottomPadding
        return header + calendar + bottom
    }

    func cellWidth(screenWidth: CGFloat) -> CGFloat {
        let containerWidth = screenWidth - Constants.calendarHorizontalSpacing * 2
        return (containerWidth - Constants.dateCellHorizontalSpacing * 6) / 7
    }

    /// 절기 그룹에 속한 날짜 셀들의 기록 데이터를 `날짜 ID -> 기록` 딕셔너리로 모아 반환한다.
    /// `TermSectionView`가 store에 의존하지 않도록, cellContext를 프로퍼티로 변환하는 단계다.
    func termRecords(
        _ termGroup: SolarTermGroup,
        context: TermRecordContext
    ) -> [SolarTermDate.ID: CalendarDateRecord] {
        var records: [SolarTermDate.ID: CalendarDateRecord] = [:]
        for week in termGroup.cells {
            for cell in week {
                guard case let .dateCell(date) = cell,
                      let record = CalendarFeature.State.dateData(date, in: context)
                else { continue }
                records[date.id] = record
            }
        }
        return records
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
    static let termSectionHeaderHeight: CGFloat = CalendarAnchorMetrics.termSectionHeaderHeight
    static let termSectionBottomPadding: CGFloat = 12
    static let weekSectionVerticalSpacing: CGFloat = CalendarAnchorMetrics.weekSectionVerticalSpacing
    static let tableBottomPadding: CGFloat = 300

    static let dateCellHorizontalSpacing: CGFloat = 7
    static let dateCellAnchorOffset: CGFloat = 11

    static var detailViewTopPadding: CGFloat {
        CalendarAnchorMetrics.cellHeight + 12
    }
}

private extension View {
    func eraseView() -> AnyView {
        AnyView(self)
    }
}
