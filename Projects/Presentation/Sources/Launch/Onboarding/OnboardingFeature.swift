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
        public var path = StackState<Path.State>()

        public init() {}
    }

    public enum Action {
        case delegate(Delegate)
        case onAppear
        case authorizationStatusChecked(NotificationAuthorizationStatus)
        case path(StackActionOf<Path>)
    }

    public enum Delegate {
        case onboardingCompleted
    }

    @Reducer
    public enum Path {
        case notificationConsent(NotificationConsentFeature)
    }

    @Dependency(\.notificationClient) var notificationClient

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
                    state.path.append(.notificationConsent(.init()))
                    return .none
                case .denied, .authorized, .provisional:
                    return .send(.delegate(.onboardingCompleted))
                }

            case .path(.element(
                id: _, action: .notificationConsent(.delegate(.completed))
            )):
                return .send(.delegate(.onboardingCompleted))

            case .delegate, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension OnboardingFeature.Path.State: Equatable {}
