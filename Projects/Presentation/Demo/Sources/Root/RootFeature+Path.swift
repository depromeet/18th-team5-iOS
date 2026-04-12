//
//  RootFeature+Path.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

extension RootFeature {
    @Reducer
    struct Path {
        enum State {
            case splash(SplashFeature.State)
            case onboarding(OnboardingFeature.State)
            case main(MainFeature.State)
        }

        enum Action {
            case splash(SplashFeature.Action)
            case onboarding(OnboardingFeature.Action)
            case main(MainFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .splash(.splashDone):
                    state = .onboarding(.init())
                    return .none
                case .onboarding(.doneButtonTapped):
                    state = .main(.init())
                    return .none
                default: return .none
                }
            }
            .ifCaseLet(\.splash, action: \.splash) {
                SplashFeature()
            }
            .ifCaseLet(\.onboarding, action: \.onboarding) {
                OnboardingFeature()
            }
            .ifCaseLet(\.main, action: \.main) {
                MainFeature()
            }
        }
    }
}
