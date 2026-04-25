//
//  RootFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Data
import Domain
import Foundation

@Reducer
public struct RootFeature {
    @ObservableState
    public struct State {
        var path: Path.State = .splash(.init())
        var launchConfig: LaunchConfig?
        var hasFetchedConfig: Bool = false

        public init() {}
    }

    public enum Action {
        case onAppear
        case path(Path.Action)
        case launchConfigLoaded(Result<LaunchConfig, Error>)
    }

    @Dependency(\.launchConfigRepository) var launchConfigRepository
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

            case .path(.onboarding(.doneButtonTapped)):
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

extension RootFeature {
    private func handleLaunchCofig(
        _ config: LaunchConfig,
        _ state: inout State
    ) -> Effect<Action> {
        state.launchConfig = config

        if config.maintenance {
            state.path = .maintenance(.init())
            return .none
        }

        if config.isForceUpdateEnabled {
            if let currentVersion = AppVersion.current,
               currentVersion < config.minimumAppVersion {
                state.path = .forceUpdate(.init())
                return .none
            }
        }
        state.path = .main(.init())
        return .none
    }
}
