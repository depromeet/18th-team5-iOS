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
                    let cards = try await calendarRecordRepository.fetchDateRecords(currentDate)
                    let displayType = try await displayType(currentDate, cards.count)

                    await send(.updateRecordCards(cards))
                    await send(.updateDetailDisplayType(displayType))
                    await send(.updateLoadingState(false))
                } catch {
                    await send(.updateLoadingState(false))
                    await send(.delegate(.showAlert(.fetchRecordFailure)))
                }
            }
        )
    }

    func displayType(_ currentDate: Date, _ cardCount: Int) async throws -> CardDetailDisplayType {
        if cardCount == 0 {
            let terms = try await solarTermRepository.fetchSolarTerms(.current)
            let currentTerm = terms.first { info in
                (info.startDate ... info.endDate).contains(.now)
            }
            let detailTerm = terms.first { info in
                (info.startDate ... info.endDate).contains(currentDate)
            }
            let isCurrentTerm = (currentTerm == detailTerm)
            return isCurrentTerm ? .emptyRecord : .passedTerm
        } else {
            return .cards
        }
    }
}
