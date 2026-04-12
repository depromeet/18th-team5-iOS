//
//  RootFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State {
        var path: Path.State = .onboarding(.init())
    }

    enum Action {
        case path(Path.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.path, action: \.path) {
            Path()
        }

        Reduce { _, _ in
            return .none
        }
    }
}
