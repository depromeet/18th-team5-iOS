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
    func 런치플로우_서버점검중() async throws {
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
    func 런치플로우_강제업데이트() async throws {
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
    func 런치플로우_원격설정획득실패() async throws {
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
}

enum TestError: Error {
    case mock
}
