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
        VStack(spacing: 36) {
            textView
            imageView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension OnboardingResultView {
    var image: Image {
        switch userType {
        case .explorer: .imgExplorer
        case .walker: .imgWalker
        case .lifeCreator: .imgLifeCreator
        case .aesthete: .imgAesthete
        }
    }
}

private extension OnboardingResultView {
    var textView: some View {
        VStack(spacing: 24) {
            Text("결과")
                .font(.body2Medium)
                .foregroundStyle(Color.gray900)
                .frame(height: 28)
                .padding(.horizontal, 10)
                .background(Color.blackAlpha200)
                .clipShape(Capsule())

            VStack(spacing: 12) {
                Text(userType.name)
                    .font(.title2Bold)
                    .foregroundStyle(Color.gray900)

                Text(userType.description)
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)
                    .multilineTextAlignment(.center)
                    .frame(height: 60, alignment: .top)
            }
        }
    }

    var imageView: some View {
        image
            .resizable()
            .frame(width: 200, height: 200)
    }
}

private extension UserType {
    var description: String {
        switch self {
        case .explorer:
            """
            꽃이 피면 꽃을 보러, 단풍이 들면 산으로.
            시간을 내서라도 직접 움직이며
            제철의 정점을 경험하는 타입이에요
            """
        case .walker:
            """
            동네 산책, 공원 한 바퀴처럼
            부담 없이 가볍게 제철을 느끼는 타입이에요.
            """
        case .lifeCreator:
            """
            제철 재료로 요리하고, 공간을 바꾸고,
            내 일상 안에 제철을 채워 넣는 타입이에요.
            """
        case .aesthete:
            """
            음악, 영화, 전시, 책처럼
            분위기로 제철을 깊게 즐기는 타입이에요.
            """
        }
    }
}
