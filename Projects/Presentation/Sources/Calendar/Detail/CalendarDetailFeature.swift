//
//  CalendarDetailFeature.swift
//  Presentation
//
//  Created by choijunios on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct CalendarDetailFeature {
    @ObservableState
    public struct State: Equatable {
        let date: Date
        var frontCardIndex: Int = 0
        var dateRecordCards: [DateRecordCard] = []
        var isLoading: Bool = true
        var toast: ToastModel?

        public init(date: Date) {
            self.date = date
        }
    }

    public enum Action: BindableAction {
        case viewDidLoad
        case removeCardButtonTapped

        // Alert
        case removeCardConfirmed
        case alert(AlertAction)

        // Internel actions
        case fetchRecordCards
        case updateRecordCards([DateRecordCard])
        case updateLoadingState(Bool)

        case delegate(Delegate)
        case binding(BindingAction<State>)

        public enum Delegate: Equatable {
            case showAlert(Alert)
            case dismissAlert
            case dismiss
        }

        public enum AlertAction: Equatable {
            case removeCardConfirmed
            case removeCardCancelled

            case retryFetchConfirmed
            case retryFetchCancelled
        }
    }

    public enum Alert: Equatable {
        case removeCard
        case fetchRecordFailure
    }

    @Dependency(\.calendarRecordRepository) var calendarRecordRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .viewDidLoad:
                return .send(.fetchRecordCards)

            case .fetchRecordCards:
                let currentDate = state.date
                return .concatenate(
                    .send(.updateLoadingState(true)),
                    .run { send in
                        do {
                            let cards = try await calendarRecordRepository.fetchDateRecords(currentDate)
                            await send(.updateRecordCards(cards))
                            await send(.updateLoadingState(false))
                        } catch {
                            await send(.delegate(.showAlert(.fetchRecordFailure)))
                        }
                    }
                )

            case let .updateRecordCards(cards):
                state.dateRecordCards = cards
                return .none

            case let .updateLoadingState(isLoading):
                state.isLoading = isLoading
                return .none

            // Alert
            case .removeCardButtonTapped:
                // TODO: 카드 식별 및 실제 삭제 처리 연결 -@준영
                return .send(.delegate(.showAlert(.removeCard)))

            case .removeCardConfirmed:
                state.toast = .init(
                    title: "기록이 삭제되었어요",
                    duration: 1.5,
                    bottomInset: 108,
                    action: nil
                )
                return .none

            case let .alert(alertAction):
                switch alertAction {
                case .removeCardConfirmed:
                    return .concatenate(
                        // TODO: 실제 카드 삭제
                        .send(.fetchRecordCards)
                    )
                case .removeCardCancelled:
                    return .send(.delegate(.dismissAlert))
                case .retryFetchConfirmed:
                    return .concatenate(
                        .send(.delegate(.dismissAlert)),
                        .send(.fetchRecordCards)
                    )
                case .retryFetchCancelled:
                    return .concatenate(
                        .send(.delegate(.dismissAlert)),
                        .send(.delegate(.dismiss))
                    )
                }

            case .delegate, .binding:
                return .none
            }
        }
    }
}
