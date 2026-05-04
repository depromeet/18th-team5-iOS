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
        var status: Status = .inProgress
        var step: Int = 1
        var firstSelection: Selection?
        var secondSelection: Selection?

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { _, _ in
            return .none
        }
    }
}
