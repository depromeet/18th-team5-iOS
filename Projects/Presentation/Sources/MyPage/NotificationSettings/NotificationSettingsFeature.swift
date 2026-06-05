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
    @Dependency(\.notificationRepository) private var notificationRepository

    @ObservableState
    public struct State: Equatable {
        let season: Season
        var authorizationStatus: NotificationAuthorizationStatus?
        var isLoading: Bool = false
        var settings: [NotificationType: Bool]?

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
        case toggleChanged(NotificationType, Bool)
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }

    public enum Delegate {
        case syncNotificationSettings([NotificationType: Bool])
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
            case let .toggleChanged(type, isOn):
                let oldValue = state.settings
                var newValue = oldValue
                newValue?[type] = isOn

                state.settings = newValue
                state.isLoading = true

                return .run { [newValue] send in
                    await setNotificationSesttings(oldValue, newValue, send)
                }
            case .binding: return .none
            case .delegate: return .none
            }
        }
    }
}

private extension NotificationSettingsFeature {
    func fetchAll(_ send: Send<Action>) async {
        async let authorizationTask: Void = fetchAuthorizationStatus(send)
        async let settingsTask: Void = fetchNotificationSettings(send)
        _ = await (authorizationTask, settingsTask)
    }

    func fetchAuthorizationStatus(_ send: Send<Action>) async {
        let status = try? await notificationClient.getAuthorizationStatus()
        await send(.set(\.authorizationStatus, status))
    }

    func fetchNotificationSettings(_ send: Send<Action>) async {
        do {
            let settings = try await notificationRepository.fetchNotificationSettings()
            await send(.set(\.settings, settings))
        } catch {
            // TODO: 추후 구현 예정 - @정원
        }
    }

    func setNotificationSesttings(
        _ oldValue: [NotificationType: Bool]?,
        _ newValue: [NotificationType: Bool]?,
        _ send: Send<Action>
    ) async {
        do {
            guard let settings = newValue else { return }
            let newSettings = try await notificationRepository.setNotificationSettings(settings)

            if let newSettings {
                await send(.delegate(.syncNotificationSettings(newSettings)))
            }

            await send(.set(\.settings, newSettings))
            await send(.set(\.isLoading, false))
        } catch {
            // TODO: Alert 처리 - @정원
            await send(.set(\.settings, oldValue))
            await send(.set(\.isLoading, false))
        }
    }
}
