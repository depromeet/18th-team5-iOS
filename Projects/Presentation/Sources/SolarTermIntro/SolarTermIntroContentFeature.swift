//
//  SolarTermIntroContentFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct SolarTermIntroContentFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        var solarTermIntro: SolarTermIntro
        var season: Season = .currentSeason
        var dateLabel: String
    }

    public enum Action {
        case onTapBack
        case onMissionTap
        case delegate(Delegate)

        public enum Delegate {
            case dismiss
            case navigateToMissionTab
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onTapBack:
                return .send(.delegate(.dismiss))

            case .onMissionTap:
                return .send(.delegate(.navigateToMissionTab))

            case .delegate:
                return .run { _ in await dismiss() }
            }
        }
    }
}
