//
//  OnboardingSurveyView.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct OnboardingSurveyView: View {
    private let store: StoreOf<OnboardingSurveyFeature>

    public init(store: StoreOf<OnboardingSurveyFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            OnboardingReadyView()
            startButton
        }
    }
}

private extension OnboardingSurveyView {
    var startButton: some View {
        Button {} label: {
            Text("시작하기")
                .font(.body2Medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(Color(hex: 0xF9FAFB))
                .background(Color(hex: 0x1F2937))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
