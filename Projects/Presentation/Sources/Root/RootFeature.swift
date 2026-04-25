//
//  RootFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
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
    }

    @Dependency(\.launchConfigRepository) var launchConfigRepository
    @Dependency(\.onboardingRepository) var onboardingRepository
    @Dependency(\.openURL) var openURL

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
                return handleLaunchCofig(config, &state)

            case .launchConfigLoaded(.failure):
                // 스플래쉬 노출 유지
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
                onboardingRepository.setOnboardingCompleted()
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

extension RootFeature {
    private func handleLaunchCofig(
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

        // #3. 온보딩 수행 여부 확인
        if !onboardingRepository.isOnboardingCompleted() {
            state.path = .onboarding(.init())
            return .none
        }

        state.path = .main(.init())
        return .none
    }
}
