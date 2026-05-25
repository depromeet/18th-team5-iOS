//
//  MissionSearchResultFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MissionSearchResultFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        // TODO: MOCK 데이터 - 추후에 수정 예정
        let solarTerm: SolarTerm = .ibha
        let locationType: LocationType = .indoor
        let participationType: ParticipationType = .together
        let category: MissionSearchCategory = .food

        public init() {}

        var season: Season {
            solarTerm.season
        }
    }

    public enum Action {
        case backButtonTapped
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            }
        }
    }
}
