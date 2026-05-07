//
//  OnboardingFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct OnboardingFeature {
    @ObservableState
    public struct State: Equatable {
        public var path: Path.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case authorizationStatusChecked(NotificationAuthorizationStatus)
        case delegate(Delegate)
        case path(Path.Action)
    }

    public enum Delegate {
        case onboardingCompleted
    }

    @Dependency(\.notificationClient) private var notificationClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let status = try await notificationClient.getAuthorizationStatus()
                    await send(.authorizationStatusChecked(status))
                }

            case let .authorizationStatusChecked(status):
                switch status {
                case .notDetermined:
                    state.path = .notificationConsent(.init())
                    return .none
                case .denied, .authorized, .provisional:
                    state.path = .survey(.init())
                    return .none
                }

            case .path(.notificationConsent(.delegate(.completed))):
                state.path = .survey(.init())
                return .none

            case .path: return .none

            case .delegate: return .none
            }
        }
        .ifLet(\.path, action: \.path) {
            Path.body
        }
    }
}

extension OnboardingFeature {
    @Reducer
    public enum Path {
        case notificationConsent(NotificationConsentFeature)
        case survey(OnboardingSurveyFeature)
    }
}

extension OnboardingFeature.Path.State: Equatable {}
