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
    func 런치플로우_온보딩_미완료시_온보딩화면이동() async {
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
        await sut.receive(\.launchConfigLoaded) {
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
        await sut.receive(\.launchConfigLoaded) {
            // Then
            $0.path = .main(.init())
        }
    }

    @Test
    func 온보딩_완료시_플래그_저장() async {
        // Given
        var didSaveFlag = false
        var state = RootFeature.State()
        state.path = .onboarding(.init())
        let sut = TestStore(initialState: state) {
            RootFeature()
        } withDependencies: {
            $0.onboardingRepository.setOnboardingCompleted = { didSaveFlag = true }
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.path(.onboarding(.delegate(.onboardingCompleted)))) {
            // Then
            $0.path = .main(.init())
        }

        #expect(didSaveFlag == true)
    }
}

enum TestError: Error {
    case mock
}
