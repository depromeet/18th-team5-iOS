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
    @Dependency(\.notificationClient) private var notificationClient

    @ObservableState
    public struct State: Equatable {
        let season: Season
        var authorizationStatus: NotificationAuthorizationStatus?
        var isLoading: Bool = false

        // TODO: 이후에 하드코딩 제거 예정 - @정원
        var settings: [NotificationType: Bool]? = [
            .solarTermStart: false,
            .solarTermEnd: false,
            .dailyMission: true
        ]

        public init(_ season: Season) {
            self.season = season
        }

        var isAuthorized: Bool? {
            guard let authorizationStatus else { return nil }

            return switch authorizationStatus {
            case .authorized, .provisional: true
            case .denied, .notDetermined: false
            }
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case appDidBecomeActive
        case backButtonTapped
        case bannerTapped
        case binding(BindingAction<State>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await fetchAll(send)
                    await send(.set(\.isLoading, false))
                }
            case .appDidBecomeActive:
                state.isLoading = true
                return .run { send in
                    await fetchAuthorizationStatus(send)
                    await send(.set(\.isLoading, false))
                }
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case .bannerTapped:
                return .none
            case .binding: return .none
            }
        }
    }
}

private extension NotificationSettingsFeature {
    func fetchAll(_ send: Send<Action>) async {
        await fetchAuthorizationStatus(send)
    }

    func fetchAuthorizationStatus(_ send: Send<Action>) async {
        let status = try? await notificationClient.getAuthorizationStatus()
        await send(.set(\.authorizationStatus, status))
    }
}
