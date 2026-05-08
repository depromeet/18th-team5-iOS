//
//  DebugTokenSettingFeature.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct DebugTokenSettingFeature {
    @ObservableState
    public struct State: Equatable {
        public var tokenText: String = ""

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case useCommonTokenButtonTapped
        case confirmButtonTapped
        case delegate(Delegate)
    }

    public enum Delegate {
        case completed
    }

    @Dependency(\.tokenRepository) var tokenRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .useCommonTokenButtonTapped:
                let commonToken = "AAAA-AAAA-AAAA-AAAA"
                state.tokenText = commonToken
                tokenRepository.setDebugDeviceToken(commonToken)
                return .send(.delegate(.completed))

            case .confirmButtonTapped:
                let token = state.tokenText
                guard token.count >= 5 else { return .none }
                tokenRepository.setDebugDeviceToken(token)
                return .send(.delegate(.completed))

            case .delegate:
                return .none
            }
        }
    }
}
