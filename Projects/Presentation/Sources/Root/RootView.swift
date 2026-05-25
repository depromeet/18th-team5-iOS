//
//  RootView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct RootView: View {
    private let store: StoreOf<RootFeature>

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            switch store.scope(state: \.path, action: \.path).case {
            case let .splash(store): SplashView(store: store)
            case let .forceUpdate(store): ForceUpdateView(store: store)
            case let .maintenance(store): MaintenanceView(store: store)
            case let .notificationConsent(store): NotificationConsentView(store: store)
            case let .survey(store): OnboardingSurveyView(store: store)
            case let .main(store): MainView(store: store)
            case let .debugToken(store): DebugTokenSettingView(store: store)
            }
        }
        .animation(.easeInOut, value: store.path)
        .onAppear { store.send(.onAppear) }
    }
}
