//
//  NotificationConsentFeature.swift
//  Presentation
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct NotificationConsentFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case delegate(Delegate)
        case agreeButtonTapped
        case disagreeButtonTapped
        case authorizationResponse(granted: Bool)
    }

    public enum Delegate {
        case completed
    }

    @Dependency(\.notificationClient) var notificationClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .agreeButtonTapped:
                return .run { send in
                    let granted = await notificationClient.requestAuthorization()
                    await send(.authorizationResponse(granted: granted))
                }

            case .disagreeButtonTapped:
                return .run { send in
                    await notificationClient.requestProvisionalAuthorization()
                    await send(.delegate(.completed))
                }

            case let .authorizationResponse(granted: _):
                return .send(.delegate(.completed))

            case .delegate:
                return .none
            }
        }
    }
}
