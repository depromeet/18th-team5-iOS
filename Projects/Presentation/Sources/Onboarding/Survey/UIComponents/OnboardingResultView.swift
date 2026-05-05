//
//  OnboardingResultView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct OnboardingResultView: View {
    private let userType: UserType

    init(userType: UserType) {
        self.userType = userType
    }

    var body: some View {
        VStack(spacing: 40) {
            textView
            graphicView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension OnboardingResultView {
    var textView: some View {
        VStack(spacing: 24) {
            Text("결과")
                .font(.body2Regular)
                .foregroundStyle(Color.gray800)
                .frame(height: 25)
                .padding(.horizontal, 8)
                .background(Color(hex: 0xE5E7EB))
                .clipShape(RoundedRectangle(cornerRadius: .radius4))

            Text(userType.name)
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray800)

            Text("\(userType.description)\n당신에게 딱 맞는 미션을 준비했어요.")
                .font(.body2Regular)
                .foregroundStyle(Color(hex: 0x9CA3AF))
                .multilineTextAlignment(.center)
        }
    }

    var graphicView: some View {
        Text("Graphic")
            .font(.headline1Semibold)
            .foregroundStyle(Color.gray400)
            .frame(width: 200, height: 200)
            .background(Color.gray200)
    }
}

private extension UserType {
    var description: String {
        switch self {
        case .natureExplorer: "" // TODO: @정원 - 미정
        case .localWanderer: "" // TODO: @정원 - 미정
        case .seasonalGourmet:
            "지금 이 계절을 가장 맛있게 즐기는 타입이에요."
        case .dailyObserver: "" // TODO: @정원 - 미정
        }
    }
}
