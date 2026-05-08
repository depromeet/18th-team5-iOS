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
        var hasError: Bool = false

        public init() {}
    }

    public enum Action {
        case onAppear
        case onRetryTap
        case homeLoad(Result<HomeData, Error>)
        case onMissionTap
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
            case .onAppear, .onRetryTap:
                state.hasError = false
                state.isLoading = true
                return .run { send in
                    do {
                        let data = try await homeRepository.fetchHome()
                        await send(.homeLoad(.success(data)))
                    } catch {
                        await send(.homeLoad(.failure(error)))
                    }
                }

            case let .homeLoad(.success(data)):
                state.isLoading = false
                state.homeData = data
                return .none

            case .homeLoad(.failure):
                state.isLoading = false
                state.hasError = true
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

            case .onRecordTap:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
