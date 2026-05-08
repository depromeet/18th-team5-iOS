//
//  HomeFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        var homeData: HomeData?
        var isLoading: Bool = false

        public init() {}
    }

    public enum Action {
        case onAppear
        case homeLoad(Result<HomeData, Error>)
        case onMissionTap
        case onMissionEntireTap
        case onMissionRecommendTap
        case onRecordTap
        case delegate(Delegate)

        public enum Delegate {
            case navigateToMissionCamera(missionId: Int, title: String, missionType: String)
            case navigateToMissionTab
        }
    }

    @Dependency(\.homeRepository) var homeRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.homeLoad(
                        Result { try await homeRepository.fetchHome() }
                    ))
                }

            case let .homeLoad(.success(data)):
                state.isLoading = false
                state.homeData = data
                return .none

            case .homeLoad(.failure):
                state.isLoading = false
                // TODO: 에러 처리 결정 후 추후 추가 - @minkyo
                return .none

            case .onMissionTap:
                guard let mission = state.homeData?.currentMission else { return .none }
                return .send(.delegate(.navigateToMissionCamera(
                    missionId: mission.id,
                    title: mission.title,
                    missionType: mission.missionType
                )))

            case .onMissionRecommendTap:
                return .send(.delegate(.navigateToMissionTab))

            case .onMissionEntireTap, .onRecordTap:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
