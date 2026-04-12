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
        let duration: Int = 3
        var timeLeft: Int

        init() {
            self.timeLeft = duration
        }
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
                return .run { [state] send in
                    for _ in 1 ... state.duration {
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
