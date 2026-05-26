//
//  MissionSearchFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/24/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MissionSearchFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        let season: Season
        var locationType: LocationType?
        var participationType: ParticipationType?
        var category: MissionCategory?

        public init(season: Season) {
            self.season = season
        }

        var isBottomButtonEnabled: Bool {
            locationType != nil
                && participationType != nil
                && category != nil
        }
    }

    public enum Action: BindableAction {
        case closeButtonTapped
        case bottomButtonTapped
        case binding(BindingAction<State>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { _, action in
            switch action {
            case .closeButtonTapped:
                return .run { _ in await dismiss() }
            case .bottomButtonTapped:
                return .run { _ in await dismiss() }
            case .binding: return .none
            }
        }
    }
}
