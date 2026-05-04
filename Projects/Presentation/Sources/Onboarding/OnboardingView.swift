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
        switch store.scope(state: \.path, action: \.path).case {
        case let .notificationConsent(store): NotificationConsentView(store: store)
        case let .survey(store): OnboardingSurveyView(store: store)
        }
    }
}
