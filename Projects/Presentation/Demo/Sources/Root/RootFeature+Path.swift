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
            case signIn(SignInFeature.State)
            case main(MainFeature.State)
        }

        enum Action {
            case signIn(SignInFeature.Action)
            case main(MainFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .signIn(.signInButtonTapped):
                    state = .main(.init())
                    return .none
                case .main(.signOutButtonTapped):
                    state = .signIn(.init())
                    return .none
                }
            }
            .ifCaseLet(\.signIn, action: \.signIn) {
                SignInFeature()
            }
            .ifCaseLet(\.main, action: \.main) {
                MainFeature()
            }
        }
    }
}
