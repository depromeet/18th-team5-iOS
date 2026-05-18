//
//  SolarTermIntroCardView.swift
//  Presentation
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct SolarTermIntroCardView: View {
    let solarTermIntro: SolarTermIntro
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                Image.imgSummerSolarTermCard
                    .resizable()
                    .scaledToFill()

                VStack(alignment: .leading) {
                    // 상단 칩
                    HStack(spacing: 4) {
                        // TODO: 절기 모델 merge 후 절기명 수정 - @minkyo
                        chipView(text: solarTermIntro.id)
                        // TODO: 절기 모델 merge 후 날짜 연동 - @minkyo
                        chipView(text: "05.05 - 05.21")
                    }
                    .padding(.top, 18)
                    .padding(.leading, 20)

                    Spacer()

                    // 하단 텍스트
                    VStack(alignment: .leading, spacing: 8) {
                        Text(solarTermIntro.introTitle)
                            .font(.title2Bold)
                            .foregroundStyle(Color(hex: 0xFDFFD1))
                            .lineLimit(3)

                        Text(solarTermIntro.introSubTitle)
                            .font(.headline2Medium)
                            .foregroundStyle(Color(hex: 0x25784A))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 23)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: .radius20))
        }
        .buttonStyle(.plain)
    }

    private func chipView(text: String) -> some View {
        Text(text)
            .font(.caption1Semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    SolarTermIntroCardView(solarTermIntro: .mock, onTap: {})
        .frame(width: 266, height: 400)
        .padding()
}
