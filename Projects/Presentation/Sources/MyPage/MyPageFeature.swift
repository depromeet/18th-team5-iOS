//
//  MyPageFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MyPageFeature {
    @Dependency(\.dismiss) private var dismiss

    public enum Menu {
        case notificationSettings
        case announcements
        case contactUs
        case termsOfService
        case privacyPolicy
    }

    @ObservableState
    public struct State: Equatable {
        let solarTerm: SolarTerm
        var version: String = "1.3.2" // TODO: 추후 수정 예정 - @정원

        public init(_ solarTerm: SolarTerm) {
            self.solarTerm = solarTerm
        }

        var season: Season {
            solarTerm.season
        }
    }

    public enum Action {
        case backButtonTapped
        case menuTapped(Menu)
        case updateButtonTapped
        case deleteButtonTapped
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case .menuTapped:
                return .none
            case .updateButtonTapped:
                return .none
            case .deleteButtonTapped:
                return .none
            }
        }
    }
}
