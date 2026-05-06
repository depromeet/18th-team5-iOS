//
//  OnboardingSurveyFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct OnboardingSurveyFeature {
    enum Status: Equatable {
        case ready
        case inProgress
        case result
    }

    enum Selection {
        case left
        case right
    }

    @ObservableState
    public struct State: Equatable {
        var status: Status = .ready
        let stepCounts: Int = 3
        var step: Int = 0
        var firstSelection: Selection?
        var secondSelection: Selection?

        public init() {}
    }

    public enum Action: BindableAction {
        case backButtonTapped
        case bottomButtonTapped
        case binding(BindingAction<State>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                switch state.step {
                case 0: state.status = .ready
                default: state.step -= 1
                }
                return .none
            case .bottomButtonTapped:
                switch state.status {
                case .ready:
                    state.status = .inProgress
                case .inProgress:
                    switch state.step {
                    case 0 ..< 2: state.step += 1
                    case 2: state.status = .result
                    default: break
                    }
                case .result: break
                }
                return .none
            case .binding: return .none
            }
        }
    }
}
