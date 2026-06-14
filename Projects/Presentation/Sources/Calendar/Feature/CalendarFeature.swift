//
//  CalendarFeature.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct CalendarFeature {
    public enum Alert: Equatable {
        case detail(CalendarDetailFeature.Alert)
    }

    @ObservableState
    public struct State: Equatable {
        @Shared(.tabBarVisibility) var tabBarVisibility: Bool = true

        public var header: CalendarHeader?
        public var isFloatingRecordButtonExpanded: Bool = true
        public var calendarState: PagingTableViewState<SolarTermGroup> = .init(pages: [])
        public var selectedDateId: SolarTermDate.ID?
        @Presents public var detail: CalendarDetailFeature.State?
        public var alert: CustomAlertFeature<Alert>.State?
        public var isDetailViewPresenting: Bool { detail != nil }

        var termRecordData: [String: CalendarTermRecordData] = [:]
        var isAppeared: Bool = false
        var anchoredTermId: SolarTermGroup.ID?
        /// 스크롤로 상단 절기가 바뀔 때마다 증가하는 햅틱 트리거. 프로그래밍적 앵커 이동에는 반응하지 않는다.
        var anchorHapticTrigger: Int = 0
        var isPaging: Bool = false
        var currentTermId: SolarTermGroup.ID?
        var currentYear: SolarTermYear = .current
        var presentMoveToCurrentTermButton: MoveToCurrentTermButtonType?
    }

    public enum Action: BindableAction {
        case onAppear
        case viewDidLoad
        case scrollViewWillBeginDragging
        case headerBackButtonTapped
        case floatingRecordButtonTapped
        case dateCellTapped(dateId: SolarTermDate.ID, inset: CGFloat)
        case anchoredTermChanged(id: SolarTermGroup.ID)
        case calendarReachToEnd(PageEndDirection)
        case calendarTermDidDisappear(id: SolarTermGroup.ID)
        case calendarTermWillAppear(id: SolarTermGroup.ID)
        case moveToCurrentTermButtonTapped
        case detailViewDisappeared
        case detail(PresentationAction<CalendarDetailFeature.Action>)
        case alert(CustomAlertFeature<Alert>.Action)
        case delegate(Delegate)

        // Internal actions
        case yearPagesLayoutCompleted
        case calendarDataRequest(TermFetchRequest)
        case updateCurrentTermId(SolarTermGroup.ID)
        case updateCalendarPages([Page<SolarTermGroup>])
        case updateCalendarHeader(CalendarHeader)
        case updateAnchorRequest(AnchorRequest<SolarTermGroup>)
        case updateAnchoredTermId(SolarTermGroup.ID)
        case updateRowReloadRequest(RowReloadRequest<SolarTermGroup>)
        case updateTermRecordData(id: String, data: CalendarTermRecordData)
        case binding(BindingAction<State>)
    }

    public enum Delegate {
        case navigateToFreeRecord
    }

    @Dependency(\.logger) var logger
    @Dependency(\.date) var date
    @Dependency(\.solarTermRepository) var solarTermRepository
    @Dependency(\.calendarRecordRepository) var calendarRecordRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .viewDidLoad:
                return initialTask(&state)

            case .onAppear:
                return refreshAnchoredTermData(state)

            case .scrollViewWillBeginDragging:
                guard state.currentTermId != state.anchoredTermId
                else { return .none }
                state.isFloatingRecordButtonExpanded = false
                return .none

            case .headerBackButtonTapped:
                state.detail = nil
                state.calendarState.scrollEnabled = true
                if let id = state.selectedDateId {
                    state.selectedDateId = nil
                    editDateCell(&state, id: id) {
                        var newDate = $0
                        newDate.isSelected = false
                        return newDate
                    }
                }
                return .none

            case let .calendarDataRequest(request):
                return fetchCalendarData(state, request)

            case .detailViewDisappeared:
                state.$tabBarVisibility.withLock { $0 = true }
                return .none

            case let .calendarReachToEnd(direction):
                return calendarPagingRequest(&state, direction: direction)

            case let .calendarTermDidDisappear(id):
                guard let anchoredTermId = state.anchoredTermId,
                      let currentTermId = state.currentTermId,
                      currentTermId == id,
                      state.presentMoveToCurrentTermButton == nil
                else { return .none }

                guard let anchoredTermIdOffset = termOffset(
                    pages: state.calendarState.pages,
                    id: anchoredTermId
                ),
                    let currentTermIdOffset = termOffset(
                        pages: state.calendarState.pages,
                        id: currentTermId
                    )
                else { return .none }

                let button: MoveToCurrentTermButtonType = (anchoredTermIdOffset < currentTermIdOffset) ? .down : .up
                state.presentMoveToCurrentTermButton = button
                return .none

            case let .calendarTermWillAppear(id):
                if id == state.currentTermId {
                    state.presentMoveToCurrentTermButton = nil
                }
                return .none

            case .moveToCurrentTermButtonTapped:
                state.presentMoveToCurrentTermButton = nil

                guard let currentTermId = state.currentTermId else { return .none }

                let request = AnchorRequest<SolarTermGroup>(
                    itemId: currentTermId,
                    inset: nil,
                    animated: false
                )
                return .concatenate(
                    .send(.updateAnchorRequest(request)),
                    .send(.updateAnchoredTermId(currentTermId))
                )

            case let .anchoredTermChanged(termId):
                return anchoredTermChanged(&state, termGroupId: termId)

            // Detail

            case let .detail(.presented(.delegate(daction))):
                switch daction {
                case let .showAlert(alert):
                    state.alert = .init(.detail(alert))
                case .dismissAlert:
                    state.alert = nil
                case .dismiss:
                    state.detail = nil
                    state.calendarState.scrollEnabled = true
                    if let id = state.selectedDateId {
                        state.selectedDateId = nil
                        editDateCell(&state, id: id) {
                            var newDate = $0
                            newDate.isSelected = false
                            return newDate
                        }
                    }
                case .refreshAnchoredTermData:
                    return refreshAnchoredTermData(state)
                }
                return .none

            case .floatingRecordButtonTapped:
                return .send(.delegate(.navigateToFreeRecord))

            // Alert

            case .alert(.primaryButtonTapped):
                switch state.alert {
                case .init(.detail(.removeCard)):
                    return .send(.detail(.presented(.alert(.removeCardConfirmed))))
                case .init(.detail(.fetchRecordFailure)):
                    return .send(.detail(.presented(.alert(.retryFetchConfirmed))))
                default:
                    return .none
                }

            case .alert(.secondaryButtonTapped):
                switch state.alert {
                case .init(.detail(.removeCard)):
                    return .send(.detail(.presented(.alert(.removeCardCancelled))))
                case .init(.detail(.fetchRecordFailure)):
                    return .send(.detail(.presented(.alert(.retryFetchCancelled))))
                default:
                    return .none
                }

            // MARK: Internal actions

            case let .dateCellTapped(dateId, inset):
                state.$tabBarVisibility.withLock { $0 = false }
                return dateCellTapped(&state, dateId: dateId, inset: inset)

            case let .updateCurrentTermId(id):
                state.currentTermId = id
                return .none

            case let .updateCalendarHeader(header):
                state.header = header
                return .none

            case let .updateAnchorRequest(request):
                state.calendarState.anchorRequest = request
                return .none

            case let .updateAnchoredTermId(id):
                state.anchoredTermId = id
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
        .ifLet(\.$detail, action: \.detail) {
            CalendarDetailFeature()
        }
        .ifLet(\.alert, action: \.alert) {
            CustomAlertFeature()
        }
    }
}

private extension CalendarFeature {
    func termOffset(
        pages: [Page<SolarTermGroup>],
        id: SolarTermGroup.ID
    ) -> Int? {
        var offset = 0
        for page in pages {
            for item in page.items {
                if item.id == id {
                    return offset
                }
                offset += 1
            }
        }
        return nil
    }
}

extension CalendarFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case let .detail(alert): alert.alertInfo
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
