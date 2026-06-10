//
//  MissionSearchResultFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MissionSearchResultFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        // TODO: MOCK 데이터 - 추후에 수정 예정
        let solarTerm: SolarTerm = .ibha
        let mission: Mission

        public init(_ mission: Mission) {
            self.mission = mission
        }

        var season: Season {
            solarTerm.season
        }

        var locationType: LocationType? {
            mission.attribute?.locationType
        }

        var participationType: ParticipationType? {
            mission.attribute?.participationType
        }

        var category: MissionCategory? {
            mission.attribute?.category
        }
    }

    public enum Action {
        case backButtonTapped
        case bottomButtonTapped
        case delegate(Delegate)
    }

    public enum Delegate {
        case navigateToMissionRecord(Mission)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case .bottomButtonTapped:
                return .send(.delegate(.navigateToMissionRecord(state.mission)))
            case .delegate: return .none
            }
        }
    }
}
