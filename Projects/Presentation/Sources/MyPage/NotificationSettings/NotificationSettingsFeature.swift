//
//  NotificationSettingsFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct NotificationSettingsFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        let season: Season

        // TODO: 이후에 하드코딩 제거 예정 - @정원
        var settings: [NotificationType: Bool]? = [
            .solarTermStart: false,
            .solarTermEnd: false,
            .dailyMission: true
        ]

        public init(_ season: Season) {
            self.season = season
        }
    }

    public enum Action: BindableAction {
        case backButtonTapped
        case binding(BindingAction<State>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { _, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case .binding: return .none
            }
        }
    }
}
