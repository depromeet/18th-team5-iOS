//
//  SampleDelegateChildFeature.swift
//  Presentation
//
//  Created by 송민교 on 4/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// [Sample] Pattern 2 - Child (Delegate 발신측)
// 자식은 완료 사실만 delegate로 알리고, 이후 처리는 부모에게 맡김
import ComposableArchitecture

@Reducer
struct SampleDelegateChildFeature {
    @ObservableState
    struct State: Equatable {
        var inputText: String = ""
    }

    enum Action {
        case inputChange(String)
        case submitTapped
        case delegate(Delegate) // 부모에게 알릴 이벤트만 정의. 처리 로직은 부모 담당.

        enum Delegate {
            case submitted(String)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .inputChange(text):
                state.inputText = text
                return .none

            case .submitTapped:
                return .send(.delegate(.submitted(state.inputText)))

            case .delegate:
                // delegate 액션은 자식이 직접 처리하지 않음
                return .none
            }
        }
    }
}
