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
    func dateCellTapped(
        _ state: inout State,
        dateId: SolarTermDate.ID,
        inset: CGFloat
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
