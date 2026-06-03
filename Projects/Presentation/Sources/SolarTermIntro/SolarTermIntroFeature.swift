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
        @Presents var content: SolarTermIntroContentFeature.State?

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

        var fullDateLabels: [SolarTerm: String] {
            solarTermInfos.reduce(into: [:]) { result, info in
                result[info.term] = info.formattedFullDateRange
            }
        }
    }

    public enum Action {
        case onAppear
        case selectSeason(Season)
        case onCardTap(SolarTermIntro)
        case content(PresentationAction<SolarTermIntroContentFeature.Action>)
        case solarTermsLoad([SolarTermIntro])
        case solarTermInfosLoad([SolarTermInfo])
        case presentContent(SolarTermIntro, String, [String: [URL]])
        case delegate(Delegate)

        public enum Delegate {
            case navigateToMissionTab
        }
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
                        let infos = try await solarTermRepository.fetchSolarTerms(.current)
                        await send(.solarTermInfosLoad(infos))
                    }
                )

            case let .solarTermsLoad(cards):
                state.allCards = cards
                return .none

            case let .solarTermInfosLoad(infos):
                state.solarTermInfos = infos
                if state.targetTerm == nil, state.season == .currentSeason {
                    let now = Date()
                    if let current = infos.first(where: { $0.dateRange.contains(now) }) {
                        state.targetTerm = current.term
                        state.season = current.term.season
                    }
                }
                return .none

            case let .selectSeason(season):
                state.season = season
                return .none

            case let .onCardTap(solarTermIntro):
                let dateLabel = state.fullDateLabels[solarTermIntro.term]
                return .run { send in
                    let urlDictionary = await solarTermIntroRepository.fetchContentImageURLs(solarTermIntro.contents)
                    await send(.presentContent(solarTermIntro, dateLabel ?? "", urlDictionary))
                }

            case let .presentContent(solarTermIntro, dateLabel, urlDictionary):
                state.content = SolarTermIntroContentFeature.State(
                    solarTermIntro: solarTermIntro,
                    season: state.season,
                    dateLabel: dateLabel,
                    imageURL: urlDictionary
                )
                return .none

            case .content(.presented(.delegate(.dismiss))):
                state.content = nil
                return .none

            case .content(.presented(.delegate(.navigateToMissionTab))):
                state.content = nil
                return .send(.delegate(.navigateToMissionTab))

            case .content:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$content, action: \.content) {
            SolarTermIntroContentFeature()
        }
    }
}
