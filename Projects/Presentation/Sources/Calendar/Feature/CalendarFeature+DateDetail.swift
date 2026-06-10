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
        // #1. 디테일 화면 데이터
        // TODO: 임시 데이터 -@준영
        state.detail = .init()

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
            state.anchoredTermId = term.id
            return .send(.updateAnchorRequest(request))
        }
        return .none
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
