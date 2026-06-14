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
    func anchoredTermChanged(
        _ state: inout State,
        termGroupId: SolarTermGroup.ID
    ) -> Effect<Action> {
        guard let anchoredTerm = findTermGroup(
            pages: state.calendarState.pages,
            termGroupId: termGroupId
        ) else { return .none }

        if termGroupId == state.currentTermId {
            state.isFloatingRecordButtonExpanded = true
        }

        let nextTrigger = state.anchorHapticTrigger + 1
        state.anchorHapticTrigger = nextTrigger % 2

        var effects: [Effect<Action>] = [
            .send(.updateCalendarHeader(mapToHeader(anchoredTerm))),
            .send(.updateAnchoredTermId(termGroupId))
        ]

        let info = anchoredTerm.solarTermInfo
        let recordKey = Self.termRecordKey(info.year, info.term)
        if let termRecordData = state.termRecordData[recordKey],
           termRecordData.data == nil {
            effects.append(
                .send(.calendarDataRequest(.specific(id: termRecordData.requestId)))
            )
        }
        return .merge(effects)
    }
}
