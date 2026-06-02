//
//  CalendarFeature+AnchorChanged.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

// MARK: - Anchor changed

extension CalendarFeature {
    func anchoredTermChanged(_ state: inout State, termId: SolarTermGroup.ID) -> Effect<Action> {
        var effects: [Effect<Action>] = []

        if let currentTerm = findTermGroup(
            pages: state.calendarState.pages,
            termId: termId
        ) {
            effects.append(
                .send(.updateCalendarHeader(mapToHeader(currentTerm)))
            )
        }

        if let term = findTermGroup(pages: state.calendarState.pages, termId: termId) {
            let info = term.solarTermInfo
            let dataId = createDataId(info.year, info.term)

            if let termRecordData = state.termRecordData[dataId],
               termRecordData.data == nil,
               !termRecordData.isInflight {
                state.termRecordData[dataId]?.flight()
                effects.append(
                    fetchCalendarData(
                        state,
                        .specific(id: termRecordData.requestId)
                    )
                )
            }
        }
        return .merge(effects)
    }
}
