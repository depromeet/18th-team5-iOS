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
                    do {
                        _ = try await notificationClient.requestAuthorization()
                        await send(.delegate(.completed))
                    } catch {
                        assertionFailure("최초 알림 동의 요청 오류")
                        await send(.delegate(.completed))
                    }
                }

            case .disagreeButtonTapped:
                return .run { send in
                    do {
                        _ = try await notificationClient.requestProvisionalAuthorization()
                        await send(.delegate(.completed))
                    } catch {
                        assertionFailure("provisional 알림 동의 요청 오류")
                        await send(.delegate(.completed))
                    }
                }

            case .delegate:
                return .none
            }
        }
    }
}
