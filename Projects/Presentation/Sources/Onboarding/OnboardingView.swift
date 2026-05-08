//
//  OnboardingView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct OnboardingView: View {
    private let store: StoreOf<OnboardingFeature>

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            if let store = store.scope(state: \.path, action: \.path) {
                switch store.case {
                case let .notificationConsent(store): NotificationConsentView(store: store)
                case let .survey(store): OnboardingSurveyView(store: store)
                }
            }
        }
        .animation(.easeInOut, value: store.path)
        .onAppear { store.send(.onAppear) }
    }
}
