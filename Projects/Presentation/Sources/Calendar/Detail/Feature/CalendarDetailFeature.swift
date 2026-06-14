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
        var shareImageItem: ShareImageItem?

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
        case deleteCardFailed(card: DateRecordCard, index: Int)
        case updateToast(ToastModel)
        case updateShareImageItem(ShareImageItem?)
        case shareCompleted(Bool)

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
    @Dependency(\.picturePermissionClient) var picturePermissionClient
    @Dependency(\.photoLibraryClient) var photoLibraryClient
    @Dependency(\.cardImageRenderer) var cardImageRenderer

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .viewDidLoad:
                return .send(.fetchRecordCards)

            case .fetchRecordCards:
                return fetchDateRecord(state)

            case .editRecordButtonTapped:
                // TODO: 기능 구현 필요
                state.toast = .init(title: "준비중입니다.", duration: 1.0, bottomInset: 108)
                return .none

            case .createRecordButtonTapped:
                // TODO: 기능 구현 필요
                state.toast = .init(title: "준비중입니다.", duration: 1.0, bottomInset: 108)
                return .none

            case .saveImageButtonTapped:
                return saveImage(&state)

            case let .updateToast(model):
                state.toast = model
                return .none

            case .shareImageButtonTapped:
                return shareImage(&state)

            case let .updateShareImageItem(item):
                state.shareImageItem = item
                return .none

            case let .shareCompleted(completed):
                state.shareImageItem = nil
                if completed {
                    state.toast = .init(title: "이미지가 공유되었어요", duration: 1.5, bottomInset: 108)
                }
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
                let removedIndex = state.frontCardIndex
                let removedCard = state.dateRecordCards.remove(at: removedIndex)
                let cardCount = state.dateRecordCards.count

                state.frontCardIndex = 0
                state.toast = .init(
                    title: "기록이 삭제되었어요",
                    duration: 1.5,
                    bottomInset: 108,
                    action: nil
                )
                let currentDate = state.date
                return .run { send in
                    if cardCount == 0 {
                        let displayType = try await displayType(currentDate)
                        await send(.updateDetailDisplayType(displayType))
                    }

                    do {
                        switch removedCard.cardType {
                        case .free:
                            try await calendarRecordRepository.deleteFreeRecord(removedCard.id)
                        case .daily, .recommended, .selected:
                            try await calendarRecordRepository.deleteMissionCompletion(removedCard.id)
                        }
                    } catch {
                        await send(.deleteCardFailed(card: removedCard, index: removedIndex))
                    }
                }

            case let .deleteCardFailed(card, index):
                // 낙관적 삭제 롤백: 제거했던 카드를 원래 위치로 복원
                let insertIndex = min(index, state.dateRecordCards.count)
                state.dateRecordCards.insert(card, at: insertIndex)
                state.frontCardIndex = insertIndex
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
