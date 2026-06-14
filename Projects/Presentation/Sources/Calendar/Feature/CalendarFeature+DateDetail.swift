//
//  CalendarFeature+DateDetail.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

// MARK: - 셀클릭 > DateDetail

extension CalendarFeature {
    /// 외부 진입(`openDetail`)을 보관했다가 pages가 준비되면 detail을 연다.
    /// 매핑이 아직 불가하면 `pendingDetailDate`를 유지한 채 `.none`을 반환해 다음 로드에서 재시도한다.
    func consumePendingDetailDateIfPossible(_ state: inout State) -> Effect<Action> {
        guard let pendingDate = state.pendingDetailDate else { return .none }
        guard !state.calendarState.pages.isEmpty,
              let anchor = findDateCellAnchor(state.calendarState.pages, matching: pendingDate)
        else { return .none }

        state.pendingDetailDate = nil
        // .dateCellTapped 핸들러와 동일하게 탭바를 숨긴 뒤 동일 흐름(스크롤+선택+detail)을 재사용한다.
        // inset은 셀 탭과 동일하게 dateCellAnchorPoint 기반으로 계산된 값을 넘긴다.
        state.$tabBarVisibility.withLock { $0 = false }
        return dateCellTapped(&state, dateId: anchor.dateId, inset: anchor.inset)
    }

    func dateCellTapped(
        _ state: inout State,
        dateId: SolarTermDate.ID,
        inset: CGFloat?
    ) -> Effect<Action> {
        guard state.selectedDateId != dateId else { return .none }

        // #1. 디테일 화면 데이터
        guard let dateModel = findDate(state.calendarState.pages, dateId),
              let date = date(from: dateModel),
              let term = findTermGroup(
                  pages: state.calendarState.pages,
                  dateId: dateId
              )?.solarTermInfo.term
        else { return .none }

        state.detail = .init(date: date, term: term)
        state.calendarState.scrollEnabled = false

        // #2. 이전 선택 셀 초기화
        let prevSelectedId = state.selectedDateId
        state.selectedDateId = dateId

        if let prevSelectedId {
            editDateCell(&state, id: prevSelectedId) { dateState in
                var newDateState = dateState
                newDateState.isSelected = false
                return newDateState
            }
        }

        // #3. 선택한 셀 선택됨으로 표시
        editDateCell(&state, id: dateId) { dateState in
            var newDateState = dateState
            newDateState.isSelected = true
            return newDateState
        }

        // #4. 해당 셀 위치로 스크롤
        if let term = findTermGroup(
            pages: state.calendarState.pages,
            dateId: dateId
        ) {
            let request = AnchorRequest<SolarTermGroup>(
                itemId: term.id,
                inset: inset,
                animated: true
            )
            return .concatenate(
                .send(.updateAnchoredTermId(term.id)),
                .send(.updateAnchorRequest(request))
            )
        }
        return .none
    }

    func date(from date: SolarTermDate) -> Date? {
        var cmp = DateComponents()
        cmp.calendar = Calendar(identifier: .gregorian)
        cmp.year = date.year.rawValue
        cmp.month = date.month
        cmp.day = date.day
        return cmp.date
    }

    func findDate(
        _ pages: [Page<SolarTermGroup>],
        _ id: SolarTermDate.ID
    ) -> SolarTermDate? {
        for pageIndex in pages.indices {
            for termIndex in pages[pageIndex].items.indices {
                let term = pages[pageIndex].items[termIndex]
                for weekIndex in term.cells.indices {
                    for dateIndex in term.cells[weekIndex].indices {
                        let cell = term.cells[weekIndex][dateIndex]
                        if case let .dateCell(date) = cell, date.id == id {
                            return date
                        }
                    }
                }
            }
        }
        return nil
    }

    /// `findDate(_:_:)`(id→date)의 역방향. Foundation Date의 연/월/일과 일치하는 셀의
    /// dateId와, 셀이 속한 주(week)의 `dateCellAnchorPoint` 기반 스크롤 inset을 함께 반환한다.
    func findDateCellAnchor(
        _ pages: [Page<SolarTermGroup>],
        matching date: Date
    ) -> (dateId: SolarTermDate.ID, inset: CGFloat)? {
        let calendar = Calendar(identifier: .gregorian)
        let cmp = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = cmp.year, let month = cmp.month, let day = cmp.day else { return nil }

        for page in pages {
            for term in page.items {
                for (weekIndex, week) in term.cells.enumerated() {
                    for cell in week {
                        if case let .dateCell(dateModel) = cell,
                           dateModel.year.rawValue == year,
                           dateModel.month == month,
                           dateModel.day == day {
                            return (
                                dateModel.id,
                                CalendarAnchorMetrics.dateCellAnchorInset(weekIndex: weekIndex)
                            )
                        }
                    }
                }
            }
        }
        return nil
    }

    func editDateCell(
        _ state: inout State,
        id: SolarTermDate.ID,
        newState: (SolarTermDate) -> SolarTermDate
    ) {
        for pageIndex in state.calendarState.pages.indices {
            for termIndex in state.calendarState.pages[pageIndex].items.indices {
                let term = state.calendarState.pages[pageIndex].items[termIndex]
                for weekIndex in term.cells.indices {
                    for dateIndex in term.cells[weekIndex].indices {
                        let cell = term.cells[weekIndex][dateIndex]
                        if case let .dateCell(date) = cell, date.id == id {
                            state.calendarState
                                .pages[pageIndex]
                                .items[termIndex]
                                .cells[weekIndex][dateIndex] = .dateCell(newState(date))
                            return
                        }
                    }
                }
            }
        }
    }
}
