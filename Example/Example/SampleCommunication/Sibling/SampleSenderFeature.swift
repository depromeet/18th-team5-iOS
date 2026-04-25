//
//  SampleSenderFeature.swift
//  Presentation
//
//  Created by 송민교 on 4/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// [Sample] Pattern 3 - Sibling A (액션 전송)
// 형제 Reducer에 직접 접근 불가. delegate로 부모에게 알리고 부모가 형제에게 전달.
import ComposableArchitecture

@Reducer
struct SampleSenderFeature {
    @ObservableState
    struct State: Equatable {
        var message: String = ""
    }

    enum Action {
        case messageChange(String)
        case sendTap
        case delegate(Delegate)

        enum Delegate {
            case messageSend(String)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .messageChange(text):
                state.message = text
                return .none

            case .sendTap:
                return .send(.delegate(.messageSend(state.message)))

            case .delegate:
                return .none
            }
        }
    }
}
