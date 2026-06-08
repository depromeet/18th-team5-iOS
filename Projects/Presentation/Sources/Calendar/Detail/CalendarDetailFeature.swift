//
//  CalendarDetailFeature.swift
//  Presentation
//
//  Created by choijunios on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem

@Reducer
public struct CalendarDetailFeature {
    public enum Alert: Equatable {
        case removeCard
    }

    @ObservableState
    public struct State: Equatable {
        // TODO: 임시모델 -@준영
        var cards: [DateCard] = Array(repeating: .init(), count: 10)
        var toast: ToastModel?

        public init() {}
    }

    public enum Action: BindableAction {
        case removeCardButtonTapped
        case removeCardConfirmed
        case delegate(Delegate)
        case binding(BindingAction<State>)

        public enum Delegate: Equatable {
            case showAlert(Alert)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce {
            state,
                action in
            switch action {
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

            case .delegate,
                 .binding:
                return .none
            }
        }
    }
}
