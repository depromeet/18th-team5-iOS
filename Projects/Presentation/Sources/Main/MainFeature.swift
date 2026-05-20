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
        var home: HomeFeature.State = .init()

        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
    }

    @Dependency(\.logger) var logger

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Reduce { _, action in
            switch action {
            case .onAppear:
                // TODO: 로깅 테스트용 호출입니다. 추후 제거부탁드립니다.
                logger.debug(message: "MainView did appear")
                return .none

            case .home(.delegate(.navigateToMissionCamera)):
                // TODO: 카메라 화면(미션 기록하기) 페이지 이동 - @minkyo
                return .none

            case .home(.delegate(.navigateToMissionTab)):
                // TODO: 미션 추천 페이지 이동 - @minkyo
                return .none

            case .home, .binding:
                return .none
            }
        }
    }
}

public extension MainFeature {
    enum Tab: CaseIterable {
        case home
        case mission
        case calendar
        case solarTerm
    }
}
