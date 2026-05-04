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
        public var path: Path.State

        public init(_ status: NotificationAuthorizationStatus?) {
            path = switch status {
            case .notDetermined, .none: .notificationConsent(.init())
            case .denied, .authorized, .provisional: .survey(.init())
            }
        }
    }

    public enum Action {
        case delegate(Delegate)
        case path(Path.Action)
    }

    public enum Delegate {
        case onboardingCompleted
    }

    @Dependency(\.notificationClient) var notificationClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.path, action: \.path) {
            Path.body
        }

        Reduce { state, action in
            switch action {
            case .path(.notificationConsent(.delegate(.completed))):
                state.path = .survey(.init())
                return .none

            case .path: return .none

            case .delegate: return .none
            }
        }
    }
}

public extension OnboardingFeature {
    @Reducer
    enum Path {
        case notificationConsent(NotificationConsentFeature)
        case survey(OnboardingSurveyFeature)
    }
}

extension OnboardingFeature.Path.State: Equatable {}
