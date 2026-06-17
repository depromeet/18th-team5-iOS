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
        var isCurrentTerm: Bool = false

        public init(term: SolarTerm) {
            self.term = term
            self.season = term.season
        }

        public init(intro: SolarTermIntro, dateLabel: String, isCurrentTerm: Bool) {
            self.term = intro.term
            self.season = intro.term.season
            self.solarTermIntro = intro
            self.dateLabel = dateLabel
            self.isCurrentTerm = isCurrentTerm
            self.isLoading = false
        }
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

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
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
