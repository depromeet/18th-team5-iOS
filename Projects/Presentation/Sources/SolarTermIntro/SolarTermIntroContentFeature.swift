//
//  SolarTermIntroContentFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct SolarTermIntroContentFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        let term: SolarTerm
        var solarTermIntro: SolarTermIntro?
        var season: Season
        var dateLabel: String = ""
        var imageURL: [String: [URL]] = [:]
        var isLoading: Bool = true

        public init(term: SolarTerm) {
            self.term = term
            self.season = term.season
        }
    }

    public enum Action {
        case onAppear
        case introLoaded(SolarTermIntro, String)
        case imageURLsLoad([String: [URL]])
        case onTapBack
        case onMissionTap
        case delegate(Delegate)

        public enum Delegate {
            case dismiss
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
                guard state.solarTermIntro == nil else { return .none }
                state.isLoading = true
                return .run { [term = state.term] send in
                    async let cards = solarTermIntroRepository.fetchSolarTermCard()
                    async let infos = solarTermRepository.fetchSolarTerms(.current)
                    guard let (fetchedCards, fetchedInfos) = try? await (cards, infos),
                          let card = fetchedCards.first(where: { $0.term == term }) else { return }
                    let dateLabel = fetchedInfos.first { $0.term == term }?.formattedFullDateRange ?? ""
                    await send(.introLoaded(card, dateLabel))
                    let urlDictionary = await solarTermIntroRepository.fetchContentImageURLs(card.contents)
                    await send(.imageURLsLoad(urlDictionary))
                }

            case let .introLoaded(intro, dateLabel):
                state.solarTermIntro = intro
                state.dateLabel = dateLabel
                state.isLoading = false
                return .none

            case let .imageURLsLoad(urlDictionary):
                state.imageURL = urlDictionary
                return .none

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
