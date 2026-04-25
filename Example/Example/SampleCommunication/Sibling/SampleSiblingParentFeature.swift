//
//  SampleSiblingParentFeature.swift
//  Presentation
//
//  Created by 송민교 on 4/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// [Sample] Pattern 3 - 부모
// Sender의 delegate를 받아 Receiver에게 전달. 형제끼리는 직접 소통 불가.
import ComposableArchitecture

@Reducer
struct SampleSiblingParentFeature {
    @ObservableState
    struct State: Equatable {
        var sender: SampleSenderFeature.State = .init()
        var receiver: SampleReceiverFeature.State = .init()
    }

    enum Action {
        case sender(SampleSenderFeature.Action)
        case receiver(SampleReceiverFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.sender, action: \.sender) {
            SampleSenderFeature()
        }
        Scope(state: \.receiver, action: \.receiver) {
            SampleReceiverFeature()
        }

        Reduce { _, action in
            switch action {
            case let .sender(.delegate(.messageSend(message))):
                // Sender delegate → Receiver로 전달
                return .send(.receiver(.receive(message)))

            case .sender, .receiver:
                return .none
            }
        }
    }
}
