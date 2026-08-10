//
//  RootView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import SwiftUI
import UIKit

public struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
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
        .onChange(of: scenePhase) { _, scenePhase in
            guard scenePhase == .active else { return }
            store.send(.appDidBecomeActive)
        }
        .onChange(of: store.season) { _, season in
            guard let season,
                  UIApplication.shared.supportsAlternateIcons,
                  UIApplication.shared.alternateIconName != season.appIconName else {
                return
            }

            Task {
                try? await Task.sleep(for: .seconds(1))
                try? await UIApplication.shared.setAlternateIconName(season.appIconName)
            }
        }
    }
}

private extension Season {
    var appIconName: String? {
        switch self {
        case .spring: "Spring"
        case .summer: "Summer"
        case .autumn: nil
        case .winter: "Winter"
        }
    }
}
