//
//  OnboardingSurveyFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct OnboardingSurveyFeature {
    enum Status: Equatable {
        case initial
        case inProgress
        case result
    }

    @ObservableState
    public struct State: Equatable {
        var status: Status = .initial
        let stepCount: Int = 3
        var step: Int = 0
        var preference: UserPreference = .init()

        public init() {}

        var userType: UserType? {
            preference.userType
        }
    }

    public enum Action: BindableAction {
        case backButtonTapped
        case bottomButtonTapped
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }

    public enum Delegate {
        case onboardingCompleted
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                switch state.step {
                case 0: state.status = .initial
                default: state.step -= 1
                }
                return .none
            case .bottomButtonTapped:
                switch state.status {
                case .initial:
                    state.status = .inProgress
                    return .none
                case .inProgress:
                    switch state.step {
                    case 0 ..< 2: state.step += 1
                    case 2: state.status = .result
                    default: break
                    }
                    return .none
                case .result:
                    return .send(.delegate(.onboardingCompleted))
                }
            case .binding: return .none
            case .delegate: return .none
            }
        }
    }
}
