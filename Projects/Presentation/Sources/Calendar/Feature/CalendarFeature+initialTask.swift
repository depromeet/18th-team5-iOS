//
//  CalendarFeature+initialTask.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

// MARK: - InitialTask

extension CalendarFeature {
    func initialTask(_ state: inout State) -> Effect<Action> {
        guard !state.isAppeared else { return .none }
        state.isAppeared = true

        let now = date.now
        guard let year = Calendar.current.dateComponents([.year], from: now).year,
              let currentYear = SolarTermYear(rawValue: year)
        else {
            assertionFailure("해당하는 연도 정보를 획득할 수 없습니다.")
            return .none
        }
        state.currentYear = currentYear
        return .concatenate(
            fetchInitialPages(currentYear: currentYear, now: now),
            fetchCalendarData(state, .today)
        )
    }
}
