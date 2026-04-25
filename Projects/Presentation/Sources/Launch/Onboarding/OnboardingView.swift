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
    @Bindable private var store: StoreOf<OnboardingFeature>

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Color.clear
                .onAppear {
                    store.send(.onAppear)
                }
        } destination: { store in
            switch store.case {
            case let .notificationConsent(store):
                NotificationConsentView(store: store)
            }
        }
    }
}
