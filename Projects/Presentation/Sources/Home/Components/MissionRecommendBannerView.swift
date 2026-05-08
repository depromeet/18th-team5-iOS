//
//  MissionRecommendBannerView.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct MissionRecommendBannerView: View {
    let onTap: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text("💡")
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("기록하고 싶은 미션이 없다면?")
                        .font(.body2Regular)
                        .foregroundStyle(Color.gray600)

                    Text("미션 추천 받기")
                        .font(.body1Semibold)
                        .foregroundStyle(Color(hex: 0x1D293D))
                }
            }

            Spacer()

            Button(action: onTap) {
                Text("이동")
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray700)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray300)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xECFBF3), Color(hex: 0xF3F4F5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

#Preview {
    MissionRecommendBannerView(onTap: {})
}
