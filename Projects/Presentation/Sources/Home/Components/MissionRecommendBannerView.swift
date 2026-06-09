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
                Image.icMission
                    .resizable()
                    .frame(width: 40, height: 40)

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
                Image.icArrowRight
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray600)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
    }
}

#Preview {
    MissionRecommendBannerView(onTap: {})
}
