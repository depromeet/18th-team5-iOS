//
//  MainFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct MainFeature {
    @ObservableState
    public struct State {
        public var tab: Tab = .home

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { _, action in
            switch action {
            case .binding:
                return .none
            }
        }
    }
}

public extension MainFeature {
    enum Tab: CaseIterable {
        case home
        case archive
        case myPage
    }
}
