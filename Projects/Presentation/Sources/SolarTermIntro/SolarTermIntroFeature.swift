//
//  SolarTermIntroFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct SolarTermIntroFeature {
    @ObservableState
    public struct State: Equatable {
        var allCards: [SolarTermIntro] = []
        var solarTermInfos: [SolarTermInfo] = []
        var season: Season = .currentSeason
        var currentTerm: SolarTerm?
        var targetTerm: SolarTerm?
        var currentCardImageURL: URL?
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

        var dateLabels: [SolarTerm: String] = [:]
        var fullDateLabels: [SolarTerm: String] = [:]
        var alert: CustomAlertFeature<Alert>.State?
    }

    public enum Alert: Equatable {
        case loadFailed
    }

    public enum Action {
        case onAppear
        case loadFailed
        case selectSeason(Season)
        case scrolledToCard(SolarTerm)
        case onCardTap(SolarTermIntro)
        case content(PresentationAction<SolarTermIntroContentFeature.Action>)
        case solarTermsLoad([SolarTermIntro])
        case solarTermInfosLoad([SolarTermInfo])
        case currentCardImageURLLoaded(URL)
        case alert(CustomAlertFeature<Alert>.Action)
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
                return .run { send in
                    do {
                        async let cards = solarTermIntroRepository.fetchSolarTermCard()
                        async let infos = solarTermRepository.fetchSolarTerms(.current)
                        let (fetchedCards, fetchedInfos) = try await (cards, infos)
                        await send(.solarTermsLoad(fetchedCards))
                        await send(.solarTermInfosLoad(fetchedInfos))
                    } catch {
                        await send(.loadFailed)
                    }
                }

            case .loadFailed:
                state.alert = CustomAlertFeature<Alert>.State(.loadFailed)
                return .none

            case .alert(.primaryButtonTapped):
                state.alert = nil
                return .send(.onAppear)

            case .alert:
                return .none

            case let .solarTermsLoad(cards):
                state.allCards = cards
                return .none

            case let .solarTermInfosLoad(infos):
                state.solarTermInfos = infos
                state.dateLabels = infos.reduce(into: [:]) { result, info in
                    result[info.term] = info.formattedDateRange
                }
                state.fullDateLabels = infos.reduce(into: [:]) { result, info in
                    result[info.term] = info.formattedFullDateRange
                }

                if state.targetTerm == nil, state.season == .currentSeason {
                    let now = Date()
                    if let current = infos.first(where: { $0.dateRange.contains(now) }) {
                        state.currentTerm = current.term
                        state.targetTerm = current.term
                        state.season = current.term.season
                        let term = current.term
                        return .run { send in
                            let path = "solar_terms/img_\(term.rawValue)_01_1.png"
                            if let url = try? await solarTermIntroRepository.fetchImageURL(path) {
                                await send(.currentCardImageURLLoaded(url))
                            }
                        }
                    }
                }
                return .none

            case let .currentCardImageURLLoaded(url):
                state.currentCardImageURL = url
                return .none

            case let .selectSeason(season):
                state.season = season
                if season == state.currentTerm?.season {
                    state.targetTerm = state.currentTerm
                } else {
                    state.targetTerm = state.filteredCards.first?.term
                }
                return .none

            case let .scrolledToCard(term):
                guard term.season == state.season else { return .none }
                state.targetTerm = term
                return .none

            case let .onCardTap(solarTermIntro):
                let info = state.solarTermInfos.first { $0.term == solarTermIntro.term }
                let dateLabel = info?.formattedFullDateRange ?? ""
                let isCurrent = info?.dateRange.contains(Date()) ?? false
                state.content = SolarTermIntroContentFeature.State(
                    intro: solarTermIntro,
                    dateLabel: dateLabel,
                    isCurrentTerm: isCurrent
                )
                return .run { send in
                    let urlDictionary = await solarTermIntroRepository.fetchContentImageURLs(solarTermIntro.contents)
                    let allURLs = Array(urlDictionary.values.flatMap { $0 })
                    ImagePrefetchService.prefetch(allURLs)
                    await send(.content(.presented(.imageURLsLoad(urlDictionary))))
                }

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

extension SolarTermIntroFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .loadFailed:
            return AlertInfo(
                title: "데이터를 불러오지 못했어요",
                buttonTitle: "다시 시도"
            )
        }
    }
}
