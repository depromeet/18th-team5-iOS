//
//  OnboardingProgressView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct OnboardingProgressView: View {
    private let stepCount: Int
    private let currentStep: Int

    init(
        stepCount: Int,
        currentStep: Int
    ) {
        self.stepCount = stepCount
        self.currentStep = min(max(currentStep, 0), stepCount - 1)
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0 ..< stepCount, id: \.self) { step in
                Capsule()
                    .frame(width: 75, height: 6)
                    .foregroundStyle(color(step))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentStep)
    }
}

private extension OnboardingProgressView {
    func color(_ step: Int) -> Color {
        step > currentStep ? .gray300 : .gray800
    }
}
