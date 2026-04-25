//
//  OnboardingFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct OnboardingFeature {
    @ObservableState
    public struct State {
        public init() {}
    }

    public enum Action {
        case doneButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}
