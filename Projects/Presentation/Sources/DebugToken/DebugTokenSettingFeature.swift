//
//  DebugTokenSettingFeature.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

private enum Constants {
    static let commonDebugToken = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
}

@Reducer
public struct DebugTokenSettingFeature {
    @ObservableState
    public struct State: Equatable {
        public var guideText: String = ""
        public var tokenText: String = ""

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case useCommonTokenButtonTapped
        case confirmButtonTapped
        case randomButtonTapped
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
            case .useCommonTokenButtonTapped:
                state.tokenText = Constants.commonDebugToken
                return .none

            case .randomButtonTapped:
                let randomToken = UUID().uuidString
                state.tokenText = randomToken
                return .none

            case .confirmButtonTapped:
                let token = state.tokenText
                guard token.count >= 5 else { return .none }
                let result = tokenRepository.setDebugDeviceToken(token)
                if result == true {
                    return .send(.delegate(.completed))
                } else {
                    state.guideText = "오류발생 재시도"
                    return .none
                }

            default:
                return .none
            }
        }
    }
}
