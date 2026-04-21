//
//  SampleReceiverFeature.swift
//  Presentation
//
//  Created by 송민교 on 4/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// [Sample] Pattern 3 - Sibling B (액션 받기)
import ComposableArchitecture

@Reducer
struct SampleReceiverFeature {
    @ObservableState
    struct State: Equatable {
        var receivedMessages: [String] = []
    }

    enum Action {
        case receive(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .receive(message):
                state.receivedMessages.append(message)
                return .none
            }
        }
    }
}
