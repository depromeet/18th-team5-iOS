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
    @ObservableState
    public struct State: Equatable {
        var solarTermIntro: SolarTermIntro
        var season: Season = .currentSeason
        var dateLabel: String
        var imageURL: [String: [URL]] = [:]
        var isLoading: Bool = true
    }

    public enum Action {
        case onAppear
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

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [contents = state.solarTermIntro.contents] send in
                    let urlDictionary = await solarTermIntroRepository.fetchContentImageURLs(contents)
                    await send(.imageURLsLoad(urlDictionary))
                }

            case let .imageURLsLoad(urlDictionary):
                state.imageURL = urlDictionary
                state.isLoading = false
                return .none

            case .onTapBack:
                return .send(.delegate(.dismiss))

            case .onMissionTap:
                return .send(.delegate(.navigateToMissionTab))

            case .delegate:
                return .none
            }
        }
    }
}
