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
        if let store = store.scope(state: \.path.onboarding, action: \.path.onboarding) {
            OnboardingView(store: store)
        } else if let store = store.scope(state: \.path.main, action: \.path.main) {
            MainView(store: store)
        }
    }
}
