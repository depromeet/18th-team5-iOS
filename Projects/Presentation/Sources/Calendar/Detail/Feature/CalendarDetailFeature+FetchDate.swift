//
//  CalendarDetailFeature+FetchDate.swift
//  Presentation
//
//  Created by choijunios on 6/14/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

extension CalendarDetailFeature {
    func fetchDateRecord(_ state: State) -> Effect<Action> {
        let currentDate = state.date
        return .concatenate(
            .send(.updateLoadingState(true)),
            .run { send in
                do {
                    let cards = try await calendarRecordRepository.fetchDateRecords(currentDate)

                    if cards.isEmpty {
                        let terms = try await solarTermRepository.fetchSolarTerms(.current)
                        let currentTerm = terms.first { info in
                            (info.startDate ... info.endDate).contains(.now)
                        }
                        let detailTerm = terms.first { info in
                            (info.startDate ... info.endDate).contains(currentDate)
                        }
                        let isCurrentTerm = (currentTerm == detailTerm)
                        let displayType: CardDetailDisplayType = isCurrentTerm ? .emptyRecord : .passedTerm
                        await send(.updateDetailDisplayType(displayType))
                    } else {
                        await send(.updateRecordCards(cards))
                        await send(.updateDetailDisplayType(.cards))
                    }
                    await send(.updateLoadingState(false))
                } catch {
                    await send(.updateLoadingState(false))
                    await send(.delegate(.showAlert(.fetchRecordFailure)))
                }
            }
        )
    }
}
