//
//  CalendarFeature.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.tabBarVisibility) var tabBarVisibility: Bool = true

        public var header: CalendarHeader?
        public var calendarState: PagingTableViewState<SolarTermGroup> = .init(pages: [])
        public var selectedDateId: SolarTermDate.ID?
        public var calendarDetail: CalendarDetail?
        public var topMostDetailCardIndex: Int = 0

        var termRecordData: [String: CalendarTermRecordData] = [:]
        var isAppeared: Bool = false
        var anchoredTermId: SolarTermGroup.ID?
        var isPaging: Bool = false
        var currentYear: SolarTermYear = .current
    }

    public enum Action: BindableAction {
        case onAppear
        case detailOkButtonTapped
        case dateCellTapped(dateId: SolarTermDate.ID, inset: CGFloat)
        case anchoredTermChanged(id: SolarTermGroup.ID)
        case calendarReachToEnd(PageEndDirection)

        // Internal actions
        case yearPagesLayoutCompleted
        case updateCalendarPages([Page<SolarTermGroup>])
        case updateCalendarHeader(CalendarHeader)
        case updateAnchorRequest(AnchorRequest<SolarTermGroup>)
        case updateRowReloadRequest(RowReloadRequest<SolarTermGroup>)
        case updateTermRecordData(id: String, data: CalendarTermRecordData)
        case binding(BindingAction<State>)
    }

    @Dependency(\.logger) var logger
    @Dependency(\.date) var date
    @Dependency(\.solarTermRepository) var solarTermRepository
    @Dependency(\.calendarRecordRepository) var calendarRecordRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return onAppear(&state)

            case let .calendarReachToEnd(direction):
                return calendarPagingRequest(&state, direction: direction)

            case let .anchoredTermChanged(termId):
                return anchoredTermChanged(&state, termGroupId: termId)

            case .detailOkButtonTapped:
                // TODO: 동작 및 액션 수정 -@준영
                state.calendarDetail = nil
                return .none

            case .binding(\.topMostDetailCardIndex):
                // TODO: 최상단 카드 처리 -@준영
                return .none

            // MARK: Internal actions

            case let .dateCellTapped(dateId, inset):
                return dateCellTapped(&state, dateId: dateId, inset: inset)

            case let .updateCalendarHeader(header):
                state.header = header
                return .none

            case let .updateAnchorRequest(request):
                state.calendarState.anchorRequest = request
                return .none

            case let .updateCalendarPages(pages):
                state.calendarState.pages = pages
                return .none

            case .yearPagesLayoutCompleted:
                state.isPaging = false
                return .none

            case let .updateTermRecordData(id, data):
                state.termRecordData[id] = data
                return .none

            case let .updateRowReloadRequest(request):
                state.calendarState.rowReloadRequest = request
                return .none

            default:
                return .none
            }
        }
    }
}

extension CalendarFeature.State {
    func dateData(_ date: SolarTermDate) -> CalendarDateRecord? {
        let termRecordKey = CalendarFeature.termRecordKey(date.year, date.term)
        guard let termRecord = termRecordData[termRecordKey]?.data else { return nil }
        return termRecord.dates.first { dateRecord in
            let components = Calendar.current.dateComponents([.day], from: dateRecord.date)
            return components.day == date.day
        }
    }
}
