//
//  OnboardingInitialView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct OnboardingInitialView: View {
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("바쁘게 지나가는 일상도")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)

                Text("절기로 차곡차곡\n기록하세요")
                    .font(.headline1Semibold)
                    .foregroundStyle(Color.gray800)
                    .multilineTextAlignment(.center)

                graphicView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension OnboardingInitialView {
    // TODO: Wireframe에 있는 임시 뷰. 추후 삭제 예정 - 정원
    var graphicView: some View {
        Text("Graphic")
            .font(.headline1Semibold)
            .foregroundStyle(Color.gray400)
            .frame(width: 200, height: 200)
            .background(Color.gray200)
    }
}
