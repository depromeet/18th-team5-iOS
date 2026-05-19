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
        var homeCard: HomeCard?
        // TODO: 추후 API 연동시 대체
        var seasonRecord: SeasonRecord = .mock
        var isLoading: Bool = false
        var hasError: Bool = false
        @Presents var solarTermIntro: SolarTermIntroFeature.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case onRetryTap
        case homeLoad(Result<HomeCard, Error>)
        case onMissionTap
        case onMissionRecommendTap
        case onRecordTap
        case solarTermIntro(PresentationAction<SolarTermIntroFeature.Action>)
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
                        let data = try await homeRepository.fetchCard()
                        await send(.homeLoad(.success(data)))
                    } catch {
                        await send(.homeLoad(.failure(error)))
                    }
                }

            case let .homeLoad(.success(data)):
                state.isLoading = false
                state.homeCard = data
                return .none

            case let .homeLoad(.failure(error)):
                state.isLoading = false
                state.hasError = true
                // TODO: 디버그용 로그 - 확인 후 제거
                print("HomeFeature fetchHome 실패: \(error)")
                return .none

            case .onMissionTap:
                guard let mission = state.homeCard?.currentMission else { return .none }
                return .send(.delegate(.navigateToMissionCamera(
                    missionId: mission.id,
                    title: mission.title,
                    missionType: mission.missionType
                )))

            case .onMissionRecommendTap:
                return .send(.delegate(.navigateToMissionTab))

            case .onRecordTap:
                let termName = state.homeCard?.solarTerm.name
                let matchedId = SolarTerm.allCases.first { $0.koreanName == termName }?.rawValue
                state.solarTermIntro = SolarTermIntroFeature.State(currentSolarTermId: matchedId)
                return .none

            case .solarTermIntro:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$solarTermIntro, action: \.solarTermIntro) {
            SolarTermIntroFeature()
        }
    }
}
