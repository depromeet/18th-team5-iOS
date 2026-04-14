//
//  RootView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct RootView: View {
    private let store: StoreOf<RootFeature>

    init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    var body: some View {
        switch store.scope(state: \.path, action: \.path).case {
        case let .splash(store): SplashView(store: store)
        case let .onboarding(store): OnboardingView(store: store)
        case let .main(store): MainView(store: store)
        }
    }
}
