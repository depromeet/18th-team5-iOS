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
    public struct State: Equatable {
        public var tab: Tab = .home

        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
    }

    @Dependency(\.logger) var logger

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { _, action in
            switch action {
            case .onAppear:
                logger.debug(message: "MainView did appear")
                return .none
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
