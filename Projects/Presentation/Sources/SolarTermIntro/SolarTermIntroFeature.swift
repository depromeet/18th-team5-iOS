//
//  SolarTermIntroFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct SolarTermIntroFeature {
    @ObservableState
    public struct State: Equatable {
        var allCards: [SolarTermIntro] = []
        var solarTermInfos: [SolarTermInfo] = []
        var season: Season = .currentSeason
        var targetTerm: SolarTerm?

        public init(currentSolarTerm: SolarTerm? = nil) {
            if let term = currentSolarTerm {
                season = term.season
                targetTerm = term
            }
        }

        var filteredCards: [SolarTermIntro] {
            allCards.filter { $0.term.season == season }
        }

        var dateLabels: [SolarTerm: String] {
            solarTermInfos.reduce(into: [:]) { result, info in
                result[info.term] = info.formattedDateRange
            }
        }
    }

    public enum Action {
        case onAppear
        case selectSeason(Season)
        case onCardTap(SolarTermIntro)
        case solarTermsLoad([SolarTermIntro])
        case solarTermInfosLoad([SolarTermInfo])
    }

    @Dependency(\.solarTermIntroRepository) var solarTermIntroRepository
    @Dependency(\.solarTermRepository) var solarTermRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        let cards = try await solarTermIntroRepository.fetchSolarTermCard()
                        await send(.solarTermsLoad(cards))
                    },
                    .run { send in
                        let infos = try await solarTermRepository.fetchSolarTerms(year: .y2026)
                        await send(.solarTermInfosLoad(infos))
                    }
                )

            case let .solarTermsLoad(cards):
                state.allCards = cards
                return .none

            case let .solarTermInfosLoad(infos):
                state.solarTermInfos = infos
                return .none

            case let .selectSeason(season):
                state.season = season
                return .none

            case .onCardTap:
                // TODO: SolarTermDetailFeature 생성 후 @Presents var detail 추가 - @minkyo
                return .none
            }
        }
    }
}
