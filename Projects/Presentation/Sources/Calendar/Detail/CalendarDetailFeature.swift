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
        case removeCardCancelled
        case delegate(Delegate)
        case binding(BindingAction<State>)

        public enum Delegate: Equatable {
            case requestAlert(CalendarAlertModel?)
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
                let alertModel = CalendarAlertModel(
                    message: "기록을 삭제할까요?",
                    buttons: [
                        .init(id: .close, title: "닫기", style: .secondary),
                        .init(id: .confirm, title: "확인", style: .primary)
                    ]
                )
                return .send(.delegate(.requestAlert(alertModel)))

            case .removeCardCancelled:
                return .send(.delegate(.requestAlert(nil)))

            case .removeCardConfirmed:
                state.toast = .init(
                    title: "기록이 삭제되었어요",
                    duration: 1.5,
                    bottomInset: 108,
                    action: nil
                )
                return .send(.delegate(.requestAlert(nil)))

            case .delegate,
                 .binding:
                return .none
            }
        }
    }
}
