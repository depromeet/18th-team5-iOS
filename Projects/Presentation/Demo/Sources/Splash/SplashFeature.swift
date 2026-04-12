//
//  SplashFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct SplashFeature {
    @ObservableState
    struct State {
        var timeLeft: Int = 3
    }

    enum Action {
        case onAppear
        case timeElapsed
        case splashDone
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    for _ in 1 ... 3 {
                        try await Task.sleep(for: .seconds(1))
                        await send(.timeElapsed)
                    }
                }
            case .timeElapsed:
                state.timeLeft -= 1

                switch state.timeLeft == 0 {
                case true: return .send(.splashDone)
                case false: return .none
                }
            case .splashDone: return .none
            }
        }
    }
}
