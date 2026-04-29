//
//  OnboardingFeatureTests.swift
//  Presentation
//
//  Created by Claude on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
@testable import Presentation
import Testing

@Suite
@MainActor
struct OnboardingFeatureTests {
    @Test
    func 알림권한_미결정시_동의화면_push() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            OnboardingFeature()
        } withDependencies: {
            $0.notificationClient.getAuthorizationStatus = { .notDetermined }
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.onAppear)

        // Then
        await sut.receive(\.authorizationStatusChecked)
    }

    @Test
    func 알림권한_이미거부시_즉시_onboardingCompleted() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            OnboardingFeature()
        } withDependencies: {
            $0.notificationClient.getAuthorizationStatus = { .denied }
        }

        // When
        await sut.send(.onAppear)

        // Then
        await sut.receive(\.authorizationStatusChecked)
        await sut.receive(\.delegate)
    }

    @Test
    func 알림권한_이미허용시_즉시_onboardingCompleted() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            OnboardingFeature()
        } withDependencies: {
            $0.notificationClient.getAuthorizationStatus = { .authorized }
        }

        // When
        await sut.send(.onAppear)
        await sut.receive(\.authorizationStatusChecked)
        await sut.receive(\.delegate)
    }
}
