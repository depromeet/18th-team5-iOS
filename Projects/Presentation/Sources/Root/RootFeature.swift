//
//  RootFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Core
import Domain
import Foundation

@Reducer
public struct RootFeature {
    @ObservableState
    public struct State: Equatable {
        let isDebug: Bool
        let currentAppVersion: AppVersion
        var path: Path.State = .splash(.init())
        var launchConfig: LaunchConfig?
        var hasFetchedConfig: Bool = false
        var isOnboarded: Bool?

        public init(currentAppVersion: AppVersion = .current, isDebug: Bool = false) {
            self.currentAppVersion = currentAppVersion
            self.isDebug = isDebug
        }
    }

    public enum Action {
        case onAppear
        case path(Path.Action)
        case launchConfigLoaded(Result<LaunchConfig, Error>)
        case launchFlowFinished
        case loginFlowFinished(with: Result<Void, Error>)
        case onboardingStateLoaded(Bool)
        case onboardingFinished
        case setDebugTokenFinished
        case navigation(Path.State)
    }

    @Dependency(\.launchConfigRepository) var launchConfigRepository
    @Dependency(\.onboardingRepository) var onboardingRepository
    @Dependency(\.authRepository) var authRepository
    @Dependency(\.openURL) var openURL
    @Dependency(\.logger) var logger
    @Dependency(\.notificationClient) private var notificationClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.path, action: \.path) {
            Path.body
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasFetchedConfig else { return .none }
                state.hasFetchedConfig = true
                return loadLaunchConfig()

            case let .launchConfigLoaded(result):
                switch result {
                case let .success(config):
                    return handleLaunchConfig(config, &state)
                case .failure:
                    // 스플래쉬화면 유지
                    return .none
                }

            case .launchFlowFinished:
                if state.isDebug {
                    state.path = .debugToken(.init())
                    return .none
                }
                return loginFlow(&state)

            case let .loginFlowFinished(result):
                switch result {
                case .success:
                    return .run { send in await loadOnboardingState(send) }
                case let .failure(error):
                    // TODO: 로그인 실패 에러처리 - @준영
                    logger.error(message: "로그인 실패 \(error.localizedDescription)")
                    return .none
                }

            case let .onboardingStateLoaded(isOnboarded):
                state.isOnboarded = isOnboarded
                return .none

            case .onboardingFinished:
                state.path = .main(.init())
                return .none

            case .setDebugTokenFinished:
                state.path = .splash(.init())
                return login()

            case .path(.forceUpdate(.updateButtonTapped)):
                guard let config = state.launchConfig else {
                    return .none
                }
                return .run { _ in
                    if let url = URL(string: config.appStoreLink) {
                        await openURL(url)
                    }
                }

            case .path(.notificationConsent(.delegate(.completed))):
                guard let isOnboarded = state.isOnboarded else { return .none }
                let destination: Path.State = isOnboarded ? .main(.init()) : .survey(.init())
                return .send(.navigation(destination))

            case .path(.survey(.delegate(.completed))):
                return .send(.navigation(.main(.init())))

            case .path(.debugToken(.delegate(.completed))):
                return .send(.setDebugTokenFinished)

            case let .navigation(destination):
                state.path = destination
                return .none

            case .path: return .none
            }
        }
    }
}

@Reducer
public enum Path {
    case splash(SplashFeature)
    case forceUpdate(ForceUpdateFeature)
    case maintenance(MaintenanceFeature)
    case notificationConsent(NotificationConsentFeature)
    case survey(OnboardingSurveyFeature)
    case main(MainFeature)
    case debugToken(DebugTokenSettingFeature)
}

extension Path.State: Equatable {}

// MARK: Lauch

private extension RootFeature {
    func loadLaunchConfig() -> Effect<Action> {
        .run { send in
            await send(.launchConfigLoaded(
                Result { try await launchConfigRepository.fetch() }
            ))
        }
    }

    func handleLaunchConfig(
        _ config: LaunchConfig,
        _ state: inout State
    ) -> Effect<Action> {
        state.launchConfig = config

        // #1. 강제업데이트 확인
        if config.isForceUpdateEnabled {
            if state.currentAppVersion < config.minimumAppVersion {
                state.path = .forceUpdate(.init())
                return .none
            }
        }

        // #2. 서버 점검 여부 확인
        if config.maintenance {
            state.path = .maintenance(.init())
            return .none
        }

        return .send(.launchFlowFinished)
    }
}

// MARK: Login

private extension RootFeature {
    func loginFlow(_ state: inout State) -> Effect<Action> {
        // #1. 토큰 존재로 로그인 유무 확인
        if authRepository.isSignin() == true {
            return .send(.loginFlowFinished(with: .success(())))
        }

        // #2. 로그인 시도
        return login()
    }

    func login() -> Effect<Action> {
        .run { send in
            await send(.loginFlowFinished(
                with: Result { try await authRepository.login() }
            ))
        }
    }
}

// MARK: Onboarding

private extension RootFeature {
    func loadOnboardingState(_ send: Send<Action>) async {
        do {
            let isOnboarded = try await onboardingRepository.isOnboarded()
            await send(.onboardingStateLoaded(isOnboarded))
            await loadNotificationAuthorizationStatus(isOnboarded, send)
        } catch {
            // TODO: 온보딩 조회 실패 에러처리 - @준영
            logger.error(message: "온보딩 진행여부 확인 실패 \(error.localizedDescription)")
        }
    }

    func loadNotificationAuthorizationStatus(
        _ isOnboarded: Bool,
        _ send: Send<Action>
    ) async {
        do {
            let status = try await notificationClient.getAuthorizationStatus()

            switch status {
            case .authorized, .provisional:
                await notificationClient.registerForRemoteNotifications()
            default: break
            }

            switch status {
            case .notDetermined:
                await send(.navigation(.notificationConsent(.init())))
            case .authorized, .denied, .provisional:
                let destination: Path.State = isOnboarded ? .main(.init()) : .survey(.init())
                await send(.navigation(destination))
            }
        } catch {
            // TODO: 알림 권한 조회 실패 에러처리 - @정원
            logger.error(message: "알림 권한 조회 실패 \(error.localizedDescription)")
        }
    }
}
