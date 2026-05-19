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
        var season: Season = .spring

        public init(currentSolarTermId: String? = nil) {
            if let id = currentSolarTermId,
               let term = SolarTerm(rawValue: id) {
                season = term.season
            }
        }

        var filteredCards: [SolarTermIntro] {
            allCards.filter {
                guard let term = SolarTerm(rawValue: $0.id) else { return false }
                return term.season == season
            }
        }

        /// id(rawValue) → "MM.dd - MM.dd" 형식
        var dateLabels: [String: String] {
            solarTermInfos.reduce(into: [:]) { result, info in
                let start = Self.dateFormatter.string(from: info.startDate)
                let end = Self.dateFormatter.string(from: info.endDate)
                result[info.term.rawValue] = "\(start) - \(end)"
            }
        }

        private static let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "MM.dd"
            return f
        }()
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
