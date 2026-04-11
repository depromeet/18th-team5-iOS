//
//  MainFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct MainFeature {
    @ObservableState
    struct State {}

    enum Action {
        case signOutButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}
