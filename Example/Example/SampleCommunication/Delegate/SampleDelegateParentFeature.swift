//
//  SampleDelegateParentFeature.swift
//  Presentation
//
//  Created by 송민교 on 4/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// [Sample] Pattern 2 - Parent (Delegate 수신)
// 자식의 delegate 액션을 받아 부모 State 업데이트
import ComposableArchitecture

@Reducer
struct SampleDelegateParentFeature {
    @ObservableState
    struct State: Equatable {
        var lastSubmitted: String = ""
        var submitCount: Int = 0
        var child: SampleDelegateChildFeature.State = .init()
    }

    enum Action {
        case child(SampleDelegateChildFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.child, action: \.child) {
            SampleDelegateChildFeature()
        }

        Reduce { state, action in
            switch action {
            case let .child(.delegate(.submitted(text))):
                // 자식 delegate 수신 → 부모 State 업데이트
                state.lastSubmitted = text
                state.submitCount += 1
                return .none

            case .child:
                return .none
            }
        }
    }
}
