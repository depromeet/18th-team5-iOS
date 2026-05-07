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
        let currentAppVersion: AppVersion
        var path: Path.State = .splash(.init())
        var launchConfig: LaunchConfig?
        var hasFetchedConfig: Bool = false

        public init(currentAppVersion: AppVersion = .current) {
            self.currentAppVersion = currentAppVersion
        }
    }

    public enum Action {
        case onAppear
        case path(Path.Action)
        case launchConfigLoaded(Result<LaunchConfig, Error>)
        case loginCompleted(Result<Void, Error>)
    }

    @Dependency(\.launchConfigRepository) var launchConfigRepository
    @Dependency(\.onboardingRepository) var onboardingRepository
    @Dependency(\.tokenRepository) var tokenRepository
    @Dependency(\.authRepository) var authRepository
    @Dependency(\.openURL) var openURL
    @Dependency(\.logger) var logger

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

                return .run { send in
                    await send(.launchConfigLoaded(
                        Result { try await launchConfigRepository.fetch()
                        }
                    ))
                }

            case let .launchConfigLoaded(.success(config)):
                return handleLaunchConfig(config, &state)

            case .launchConfigLoaded(.failure):
                // 스플래쉬 노출 유지
                return .none

            case .loginCompleted(.success(())):
                return navigateAfterAuth(state: &state)

            case let .loginCompleted(.failure(error)):
                // TODO: 로그인 실패 에러처리 - @준영
                logger.error(message: "로그인 실패 \(error.localizedDescription)")
                return .none

            case .path(.forceUpdate(.updateButtonTapped)):
                guard let config = state.launchConfig else {
                    return .none
                }
                return .run { _ in
                    if let url = URL(string: config.appStoreLink) {
                        await openURL(url)
                    }
                }

            case .path(.onboarding(.delegate(.onboardingCompleted))):
                try? onboardingRepository.setOnboardingCompleted()
                state.path = .main(.init())
                return .none

            default:
                return .none
            }
        }
    }
}

@Reducer
public enum Path {
    case splash(SplashFeature)
    case forceUpdate(ForceUpdateFeature)
    case maintenance(MaintenanceFeature)
    case onboarding(OnboardingFeature)
    case main(MainFeature)
}

extension Path.State: Equatable {}

private extension RootFeature {
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

        // #3. 토큰 유무 확인 → 로그인 필요 시 요청
        if tokenRepository.hasTokens() {
            return navigateAfterAuth(state: &state)
        }

        return .run { send in
            await send(.loginCompleted(Result { try await authRepository.login() }))
        }
    }

    /// 로그인(또는 토큰 존재) 이후 온보딩 수행 여부에 따라 화면 분기
    func navigateAfterAuth(state: inout State) -> Effect<Action> {
        let isOnboardingCompleted = try? onboardingRepository.isOnboardingCompleted()
        if isOnboardingCompleted == true {
            state.path = .main(.init())
            return .none
        }

        state.path = .onboarding(.init())
        return .none
    }
}
