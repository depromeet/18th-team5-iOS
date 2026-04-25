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
        VStack(spacing: 20) {
            Text("온보딩 화면")

            Button("확인") {
                store.send(.doneButtonTapped)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
