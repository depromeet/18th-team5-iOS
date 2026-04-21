//
//  SampleCounterFeature.swift
//  Presentation
//
//  Created by 송민교 on 4/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// [Sample] Pattern 1 - Child Reducer
// 부모로부터 액션을 받아 처리하는 자식 Reducer
import ComposableArchitecture

@Reducer
struct SampleCounterFeature {
    @ObservableState
    struct State: Equatable {
        var count: Int = 0
    }

    enum Action {
        case increment
        case decrement
        case reset
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increment:
                state.count += 1
                return .none
            case .decrement:
                state.count -= 1
                return .none
            case .reset:
                state.count = 0
                return .none
            }
        }
    }
}
