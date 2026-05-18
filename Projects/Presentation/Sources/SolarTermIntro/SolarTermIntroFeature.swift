//
//  SolarTermIntroFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct SolarTermIntroFeature {
    @ObservableState
    public struct State: Equatable {
        var solarTermIntroCard: [SolarTermIntro] = []
        var season: Season = .spring

        public init() {}
    }

    public enum Action {
        case onAppear
        case selectSeason(Season)
        case onCardTap(SolarTermIntro)
        case delegate(Delegate)
        case solarTermsLoad([SolarTermIntro])

        public enum Delegate {
            case navigationToDetail(SolarTermIntro)
        }
    }

    @Dependency(\.solarTermIntroRepository) var solarTermIntroRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let data = try await solarTermIntroRepository.fetchSolarTermCard()
                    await send(.solarTermsLoad(data))
                }
            case let .solarTermsLoad(data):
                state.solarTermIntroCard = data
                return .none
            case let .selectSeason(season):
                state.season = season
                return .none
            case let .onCardTap(solarTermIntro):
                return .send(.delegate(.navigationToDetail(solarTermIntro)))
            case .delegate:
                return .none
            }
        }
    }
}
