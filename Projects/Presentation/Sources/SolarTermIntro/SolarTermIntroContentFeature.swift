//
//  SolarTermIntroContentFeature.swift
//  Presentation
//
//  Created by 송민교 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct SolarTermIntroContentFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        var solarTermIntro: SolarTermIntro?
        var dateLabel: String = ""
        var imageURL: [String: [URL]] = [:]
        var isLoading: Bool = true
        var isCurrentTerm: Bool = false
        var alert: CustomAlertFeature<Alert>.State?

        public init() {}
        public init(intro: SolarTermIntro, dateLabel: String, isCurrentTerm: Bool) {
            self.solarTermIntro = intro
            self.dateLabel = dateLabel
            self.isCurrentTerm = isCurrentTerm
            self.isLoading = false
        }

        var term: SolarTerm? {
            solarTermIntro?.term
        }
    }

    @Dependency(\.solarTermIntroRepository) var solarTermIntroRepository
    @Dependency(\.solarTermRepository) var solarTermRepository

    public enum Alert: Equatable {
        case loadFailed
    }

    public enum Action {
        case onAppear
        case introLoaded(SolarTermIntro, String, Bool)
        case introLoadFailed
        case imageURLsLoad([String: [URL]])
        case onTapBack
        case onMissionTap
        case alert(CustomAlertFeature<Alert>.Action)
        case delegate(Delegate)

        public enum Delegate {
            case dismiss
            case navigateToMissionTab
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // init(term:)으로 생성된 경우에만 직접 fetch
                guard state.solarTermIntro == nil else { return .none }
                state.isLoading = true
                return .run { [term = state.term] send in
                    do {
                        async let cards = solarTermIntroRepository.fetchSolarTermCard()
                        async let infos = solarTermRepository.fetchSolarTerms(.current)
                        let (fetchedCards, fetchedInfos) = try await (cards, infos)
                        guard let card = fetchedCards.first(where: { $0.term == term }) else {
                            await send(.introLoadFailed)
                            return
                        }
                        let info = fetchedInfos.first { $0.term == term }
                        let dateLabel = info?.formattedFullDateRange ?? ""
                        let isCurrent = info?.dateRange.contains(Date()) ?? false
                        await send(.introLoaded(card, dateLabel, isCurrent))
                        let urlDictionary = await solarTermIntroRepository.fetchContentImageURLs(card.contents)
                        await send(.imageURLsLoad(urlDictionary))
                    } catch {
                        await send(.introLoadFailed)
                    }
                }

            case .introLoadFailed:
                state.isLoading = false
                state.alert = CustomAlertFeature<Alert>.State(.loadFailed)
                return .none

            case .alert(.primaryButtonTapped):
                state.alert = nil
                return .send(.delegate(.dismiss))

            case .alert:
                return .none

            case let .introLoaded(intro, dateLabel, isCurrent):
                state.solarTermIntro = intro
                state.dateLabel = dateLabel
                state.isCurrentTerm = isCurrent
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

extension SolarTermIntroContentFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .loadFailed:
            return AlertInfo(
                title: "데이터를 불러오지 못했어요",
                buttonTitle: "확인"
            )
        }
    }
}
