//
//  OnboardingView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {
    private let store: StoreOf<OnboardingFeature>

    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("온보딩 화면")

            Button("확인") {
                store.send(.doneButtonTapped)
            }
        }
    }
}
