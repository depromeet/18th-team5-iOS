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
        var initialPath: Path.State?
        var splashDone: Bool = false
        var launchConfig: LaunchConfig?
        var hasFetchedConfig: Bool = false
        var isOnboarded: Bool?
        var notificationAuthorizationStatus: NotificationAuthorizationStatus?
        @Shared(.solarTerm) var solarTerm
        var season: Season?

        public init(currentAppVersion: AppVersion = .current, isDebug: Bool = false) {
            self.currentAppVersion = currentAppVersion
            self.isDebug = isDebug
        }
    }

    public enum Action {
        case onAppear
        case splashTimeout
        case appDidBecomeActive
        case path(Path.Action)
        case solarTermFetched(SolarTerm)
        case launchConfigLoaded(Result<LaunchConfig, Error>)
        case launchFlowFinished
        case loginFlowFinished(with: Result<Void, Error>)
        case onboardingStateLoaded(Bool)
        case notificationAuthorizationStatusLoaded(NotificationAuthorizationStatus)
        case onboardingFinished
        case setDebugTokenFinished
        case initialPathDetermined(Path.State)
        case navigation(Path.State)
    }

    @Dependency(\.launchConfigRepository) var launchConfigRepository
    @Dependency(\.onboardingRepository) var onboardingRepository
    @Dependency(\.authRepository) var authRepository
    @Dependency(\.openURL) var openURL
    @Dependency(\.logger) var logger
    @Dependency(\.notificationClient) private var notificationClient
    @Dependency(\.solarTermRepository) private var solarTermRepository
    @Dependency(\.analyticsClient) private var analyticsClient

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
                return .merge([
                    .run { send in await loadLaunchConfig(send) },
                    .run { send in await fetchTodaysSolarTerm(send) }
                ])

            case .path(.splash(.onAppear)):
                return .run { send in
                    try await Task.sleep(for: .seconds(8))
                    await send(.splashTimeout)
                }

            case .splashTimeout:
                guard case .splash = state.path else { return .none }
                return .send(.path(.splash(.showAlert)))

            case .path(.splash(.delegate(.refresh))):
                state = .init()
                return .concatenate([
                    .send(.onAppear),
                    .send(.path(.splash(.onAppear)))
                ])

            case .appDidBecomeActive:
                return .run { [state] send in
                    await checkNotificationAuthorizationStatusChange(state, send)
                }

            case let .solarTermFetched(solarTerm):
                state.$solarTerm.withLock { $0 = solarTerm }
                state.season = solarTerm.season
                return .none

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
                    return .run { [state] send in await
                        loadOnboardingState(state, send)
                    }
                case let .failure(error):
                    // TODO: 로그인 실패 에러처리 - @준영
                    logger.error(message: "로그인 실패 \(error.localizedDescription)")
                    return .none
                }

            case let .onboardingStateLoaded(isOnboarded):
                state.isOnboarded = isOnboarded
                return .none

            case let .notificationAuthorizationStatusLoaded(status):
                state.notificationAuthorizationStatus = status
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

            case .path(.splash(.splashDone)):
                state.splashDone = true
                guard let path = state.initialPath else { return .none }
                return .send(.navigation(path))

            case .path(.main(.delegate(.navigateToSplash))):
                state = .init()
                return .send(.onAppear)

            case let .initialPathDetermined(path):
                state.initialPath = path
                guard state.splashDone else { return .none }
                return .send(.navigation(path))

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
    func loadLaunchConfig(_ send: Send<Action>) async {
        await send(.launchConfigLoaded(
            Result { try await launchConfigRepository.fetch() }
        ))
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
    func loadOnboardingState(_ state: State, _ send: Send<Action>) async {
        do {
            let isOnboarded = try await onboardingRepository.isOnboarded()
            await send(.onboardingStateLoaded(isOnboarded))
            await loadNotificationAuthorizationStatus(isOnboarded, state, send)
        } catch {
            // TODO: 온보딩 조회 실패 에러처리 - @준영
            logger.error(message: "온보딩 진행여부 확인 실패 \(error.localizedDescription)")
        }
    }

    func loadNotificationAuthorizationStatus(
        _ isOnboarded: Bool,
        _ state: State,
        _ send: Send<Action>
    ) async {
        do {
            let status = try await notificationClient.getAuthorizationStatus()
            await send(.notificationAuthorizationStatusLoaded(status))

            switch status {
            case .authorized, .provisional:
                await notificationClient.registerForRemoteNotifications()
            default: break
            }

            switch status {
            case .notDetermined:
                await send(.initialPathDetermined(.notificationConsent(.init())))
            case .authorized, .denied, .provisional:
                let destination: Path.State = isOnboarded ? .main(.init()) : .survey(.init())
                await send(.initialPathDetermined(destination))
            }
        } catch {
            // TODO: 알림 권한 조회 실패 에러처리 - @정원
            logger.error(message: "알림 권한 조회 실패 \(error.localizedDescription)")
        }
    }

    func checkNotificationAuthorizationStatusChange(
        _ state: State,
        _ send: Send<Action>
    ) async {
        do {
            let wasAuthorized = state.notificationAuthorizationStatus?.isAuthorized ?? false
            let currentStatus = try await notificationClient.getAuthorizationStatus()
            await send(.notificationAuthorizationStatusLoaded(currentStatus))

            if !wasAuthorized, currentStatus.isAuthorized {
                await notificationClient.registerForRemoteNotifications()
            }
        } catch {
            // TODO: 알림 권한 조회 실패 에러처리 - @정원
            logger.error(message: "알림 권한 조회 실패 \(error.localizedDescription)")
        }
    }

    func fetchTodaysSolarTerm(_ send: Send<Action>) async {
        let year = SolarTermYear(rawValue: Date.now.year)
        guard let year else { return }
        let solarTerms = try? await solarTermRepository.fetchSolarTerms(year)
        let solarTerm = solarTerms?.first { $0.dateRange ~= Date.now }?.term
        guard let solarTerm else { return }
        analyticsClient.setSolarTerm(solarTerm)
        await send(.solarTermFetched(solarTerm))
    }
}

private extension NotificationAuthorizationStatus {
    var isAuthorized: Bool {
        switch self {
        case .authorized, .provisional: return true
        case .notDetermined, .denied: return false
        }
    }
}
