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
        var path: Path.State = .splash(.init())
    }

    enum Action {
        case path(Path.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.path, action: \.path) {
            Path.body
        }

        Reduce { state, action in
            switch action {
            case .path(.splash(.splashDone)):
                state.path = .onboarding(.init())
                return .none
            case .path(.onboarding(.doneButtonTapped)):
                state.path = .main(.init())
                return .none
            default:
                return .none
            }
        }
    }
}

extension RootFeature {
    @Reducer
    enum Path {
        case splash(SplashFeature)
        case onboarding(OnboardingFeature)
        case main(MainFeature)
    }
}
