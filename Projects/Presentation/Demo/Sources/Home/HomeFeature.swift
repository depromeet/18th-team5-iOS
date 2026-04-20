//
//  HomeFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State {
        var path: StackState<HomePath.State> = .init()
    }

    enum Action {
        case onAppear
        case outerPushButtonTapped
        case innerPushButtonTapped
        case path(StackActionOf<HomePath>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .innerPushButtonTapped:
                state.path.append(.mission(.init()))
                return .none
            case .outerPushButtonTapped:
                state.path.append(.notification(.init()))
                return .none
            case .path: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension HomeFeature {
    @Reducer
    enum HomePath {
        case mission(MissionFeature)
        case notification(NotificationFeature)
    }
}
