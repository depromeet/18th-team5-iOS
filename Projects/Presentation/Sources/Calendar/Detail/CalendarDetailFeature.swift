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
        var displayType: CardDetailDisplayType = .notDetermined
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
        case editRecordButtonTapped
        case saveImageButtonTapped
        case shareImageButtonTapped
        case createRecordButtonTapped

        // Alert
        case removeCardConfirmed
        case alert(AlertAction)

        // Internal actions
        case fetchRecordCards
        case updateDetailDisplayType(CardDetailDisplayType)
        case updateRecordCards([DateRecordCard])
        case updateLoadingState(Bool)
        case deleteCardFailed

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

    @Dependency(\.solarTermRepository) var solarTermRepository
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
                            await send(.delegate(.showAlert(.fetchRecordFailure)))
                        }
                    }
                )

            case .editRecordButtonTapped:
                // TODO: 기능 구현 필요
                state.toast = .init(title: "준비중입니다.", duration: 1.0, bottomInset: 108)
                return .none

            case .saveImageButtonTapped:
                // TODO: 기능 구현 필요
                state.toast = .init(title: "준비중입니다.", duration: 1.0, bottomInset: 108)
                return .none

            case .shareImageButtonTapped:
                // TODO: 기능 구현 필요
                state.toast = .init(title: "준비중입니다.", duration: 1.0, bottomInset: 108)
                return .none

            case .createRecordButtonTapped:
                // TODO: 기능 구현 필요
                state.toast = .init(title: "준비중입니다.", duration: 1.0, bottomInset: 108)
                return .none

            case let .updateRecordCards(cards):
                state.dateRecordCards = cards
                return .none

            case let .updateLoadingState(isLoading):
                state.isLoading = isLoading
                return .none

            case let .updateDetailDisplayType(type):
                state.displayType = type
                return .none

            // Alert
            case .removeCardButtonTapped:
                return .send(.delegate(.showAlert(.removeCard)))

            case .removeCardConfirmed:
                // 낙관적 업데이트: 현재 가장 위에 있는 카드를 즉시 제거
                guard state.dateRecordCards.indices.contains(state.frontCardIndex) else {
                    return .none
                }
                let removedCard = state.dateRecordCards.remove(at: state.frontCardIndex)
                state.frontCardIndex = 0
                state.toast = .init(
                    title: "기록이 삭제되었어요",
                    duration: 1.5,
                    bottomInset: 108,
                    action: nil
                )
                return .run { send in
                    do {
                        switch removedCard.cardType {
                        case .free:
                            try await calendarRecordRepository.deleteFreeRecord(removedCard.id)
                        case .daily, .recommended, .selected:
                            try await calendarRecordRepository.deleteMissionCompletion(removedCard.id)
                        }
                    } catch {
                        await send(.deleteCardFailed)
                    }
                }

            case .deleteCardFailed:
                state.toast = .init(
                    title: "카드 삭제에 실패했어요",
                    duration: 1.5,
                    bottomInset: 108,
                    action: nil
                )
                return .none

            case let .alert(alertAction):
                switch alertAction {
                case .removeCardConfirmed:
                    return .concatenate(
                        .send(.delegate(.dismissAlert)),
                        .send(.removeCardConfirmed)
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
