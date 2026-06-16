//
//  CalendarDetailFeature+FetchDate.swift
//  Presentation
//
//  Created by choijunios on 6/14/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Foundation

extension CalendarDetailFeature {
    func fetchDateRecord(_ state: State) -> Effect<Action> {
        let currentDate = state.date
        return .concatenate(
            .send(.updateLoadingState(true)),
            .run { send in
                do {
                    let displayType = try await displayType(currentDate)
                    await send(.updateDetailDisplayType(displayType))

                    guard displayType != .futureTerm else {
                        await send(.updateLoadingState(false))
                        return
                    }

                    let cards = try await calendarRecordRepository.fetchDateRecords(currentDate)
                    await send(.updateRecordCards(cards))
                    await send(.updateLoadingState(false))
                } catch {
                    await send(.updateLoadingState(false))
                    await send(.delegate(.showAlert(.fetchRecordFailure)))
                }
            }
        )
    }

    func displayType(_ currentDate: Date) async throws -> CardDetailDisplayType {
        let terms = try await solarTermRepository.fetchSolarTerms(.current)
        let nowDate: Date = .now
        let currentTerm = terms.first { info in
            (info.startDate ..< info.endDate).contains(nowDate)
        }
        let detailTerm = terms.first { info in
            (info.startDate ..< info.endDate).contains(currentDate)
        }

        guard let currentTerm, let detailTerm else { return .notDetermined }

        if currentTerm == detailTerm {
            let calendar = Calendar.current
            let tomorrowMidnight = calendar.startOfDay(
                for: calendar.date(byAdding: .day, value: 1, to: nowDate)!
            )
            return currentDate < tomorrowMidnight ? .currentTermUpToToday : .currentTermAfterToday
        }

        if currentTerm.startDate < detailTerm.startDate {
            return .futureTerm
        } else {
            return .passedTerm
        }
    }
}
