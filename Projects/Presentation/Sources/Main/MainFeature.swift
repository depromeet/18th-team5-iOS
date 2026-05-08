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
        var path: StackState<Path.State> = .init()

        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
        case logout
        case reset
        case delegate(Delegate)
        case path(StackActionOf<Path>)

        public enum Delegate {
            case reset
        }
    }

    @Dependency(\.logger) var logger
    @Dependency(\.authRepository) var authRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: 로깅 테스트용 호출입니다. 추후 제거부탁드립니다.
                logger.debug(message: "MainView did appear")
                return .none

            case let .home(.delegate(.navigateToMissionCamera(id, title, type))):
                state.path.append(.missionRecord(.init(missionTitle: title)))
                return .none

            case .home(.delegate(.navigateToMissionTab)):
                // TODO: 미션 추천 페이지 이동 - @minkyo
                return .none

            case .home, .binding:
                return .none

            case .logout:
                return .run { send in
                    try await authRepository.logout()
                    await send(.reset)
                }

            case .reset:
                return .send(.delegate(.reset))

            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

public extension MainFeature {
    enum Tab: CaseIterable {
        case home
        case archive
        case myPage
    }
}

extension MainFeature {
    @Reducer
    public enum Path {
        case missionRecord(MissionRecordFeature)
    }
}

extension MainFeature.Path.State: Equatable {}
