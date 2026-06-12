//
//  MissionCompleteView.swift
//  Presentation
//
//  Created by 이정원 on 6/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct MissionCompleteView: View {
    private let maxCount: Int
    private let deviceWidth: CGFloat = UIScreen.width

    init(maxCount: Int) {
        self.maxCount = maxCount
    }

    var body: some View {
        ZStack {
            rightGradient
            leftGradient
            infoView
        }
    }
}

private extension MissionCompleteView {
    var rightGradient: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .init(hex: 0xFFFEB3), location: 0.7)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 500, height: 500)
        .clipShape(Circle())
        .blur(radius: 50)
        .offset(x: 300 - deviceWidth / 2)
        .offset(y: -56)
    }

    var leftGradient: some View {
        LinearGradient(
            stops: [
                .init(color: .init(hex: 0xBFF4DF), location: 0.3),
                .init(color: .clear, location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 500, height: 500)
        .clipShape(Circle())
        .blur(radius: 50)
        .offset(x: -275 + deviceWidth / 2)
        .offset(y: 44)
    }

    var infoView: some View {
        VStack(spacing: 4) {
            Text("하루 \(maxCount)번 기록 가능")
                .font(.body2Regular)
                .foregroundStyle(Color.gray700)
                .frame(maxWidth: .infinity)

            let title = """
            오늘 \(maxCount)번 기록을 완료했어요!
            이 공간의 미션은 내일 다시 열려요
            """
            Text(title)
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            Image.imgCongratulation
                .resizable()
                .frame(width: 200, height: 200)
        }
    }
}
