//
//  RootFeatureTests.swift
//  Presentation
//
//  Created by choijunios on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
@testable import Presentation
import Testing

@Suite
@MainActor
struct RootFeatureTests {
    @Test
    func 런치플로우_서버점검중() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            RootFeature()
        } withDependencies: {
            $0.launchConfigRepository = .init(fetch: {
                .init(
                    maintenance: true,
                    isForceUpdateEnabled: false,
                    minimumAppVersion: .init(major: 0, minor: 0, patch: 0),
                    appStoreLink: ""
                )
            })
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.onAppear)
        await sut.receive(\.launchConfigLoaded) {
            // Then
            $0.path = .maintenance(.init())
        }
    }

    @Test
    func 런치플로우_강제업데이트() async {
        // Given
        let current = AppVersion(major: 0, minor: 0, patch: 0)
        let sut = TestStore(initialState: .init(currentAppVersion: current)) {
            RootFeature()
        } withDependencies: {
            $0.launchConfigRepository = .init(fetch: {
                .init(
                    maintenance: false,
                    isForceUpdateEnabled: true,
                    minimumAppVersion: .init(major: 1, minor: 0, patch: 0),
                    appStoreLink: ""
                )
            })
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.onAppear)
        await sut.receive(\.launchConfigLoaded) {
            // Then
            $0.path = .forceUpdate(.init())
        }
    }

    @Test
    func 런치플로우_원격설정획득실패() async {
        // Given
        let current = AppVersion(major: 0, minor: 0, patch: 0)
        let sut = TestStore(initialState: .init(currentAppVersion: current)) {
            RootFeature()
        } withDependencies: {
            $0.launchConfigRepository = .init(fetch: {
                throw TestError.mock
            })
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.onAppear)
        await sut.receive(\.launchConfigLoaded) {
            // Then
            $0.path = .splash(.init())
        }
    }

    @Test
    func 로그인후_온보딩_미완료시_온보딩화면이동() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            RootFeature()
        } withDependencies: {
            $0.launchConfigRepository = .init(fetch: {
                .init(
                    maintenance: false,
                    isForceUpdateEnabled: false,
                    minimumAppVersion: .init(major: 0, minor: 0, patch: 0),
                    appStoreLink: ""
                )
            })
            $0.onboardingRepository.isOnboardingCompleted = { false }
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.onAppear)
        await sut.receive(\.loginFlowFinished) {
            // Then
            $0.path = .onboarding(.init())
        }
    }

    @Test
    func 런치플로우_온보딩_완료시_메인화면이동() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            RootFeature()
        } withDependencies: {
            $0.launchConfigRepository = .init(fetch: {
                .init(
                    maintenance: false,
                    isForceUpdateEnabled: false,
                    minimumAppVersion: .init(major: 0, minor: 0, patch: 0),
                    appStoreLink: ""
                )
            })
            $0.onboardingRepository.isOnboardingCompleted = { true }
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.onAppear)
        await sut.receive(\.onboardingFinished) {
            // Then
            $0.path = .main(.init())
        }
    }

    @Test
    func 런치플로우_정상완료_isDebug_참이면_디버그토큰화면이동() async {
        // Given
        let sut = TestStore(initialState: .init(isDebug: true)) {
            RootFeature()
        } withDependencies: {
            $0.launchConfigRepository = .init(fetch: {
                .init(
                    maintenance: false,
                    isForceUpdateEnabled: false,
                    minimumAppVersion: .init(major: 0, minor: 0, patch: 0),
                    appStoreLink: ""
                )
            })
            $0.authRepository = AuthRepository(
                isSignin: { true },
                login: {}
            )
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.onAppear)
        await sut.receive(\.launchFlowFinished) {
            // Then - isDebug가 참이므로 디버그 토큰 설정 화면이 present 됨
            $0.path = .debugToken(.init())
        }
    }
}

enum TestError: Error {
    case mock
}
