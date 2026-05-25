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
    @ObservableState
    public struct State: Equatable {
        var solarTermIntro: SolarTermIntro
        var season: Season = .currentSeason
        var dateLabel: String
    }

    public enum Action {
        case onTapBack
        case delegate(Delegate)

        public enum Delegate {
            case dismiss
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onTapBack:
                return .send(.delegate(.dismiss))

            case .delegate:
                return .none
            }
        }
    }
}
