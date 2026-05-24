//
//  NotificationConsentFeatureTests.swift
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
struct NotificationConsentFeatureTests {
    @Test
    func 다음버튼탭_권한허용시_delegate전달() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            NotificationConsentFeature()
        } withDependencies: {
            $0.notificationClient.requestAuthorization = { true }
            $0.notificationClient.registerForRemoteNotifications = {}
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.nextButtonTapped)

        // Then
        await sut.receive(.delegate(.completed))
    }

    @Test
    func 건너뛰기탭_provisional권한요청후_delegate전달() async {
        // Given
        let sut = TestStore(initialState: .init()) {
            NotificationConsentFeature()
        } withDependencies: {
            $0.notificationClient.requestProvisionalAuthorization = {}
            $0.notificationClient.registerForRemoteNotifications = {}
        }
        sut.exhaustivity = .off

        // When
        await sut.send(.skipButtonTapped)

        // Then
        await sut.receive(.delegate(.completed))
    }
}
