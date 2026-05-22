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
    let season: Season
    let dateLabel: String?
    let onTap: () -> Void

    // TODO: 계절별 이미지 추가되면 교체 - @minkyo
    private var cardImage: Image {
        switch season {
        case .spring: .imgSummerSolarTermCard
        case .summer: .imgSummerSolarTermCard
        case .autumn: .imgSummerSolarTermCard
        case .winter: .imgSummerSolarTermCard
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                cardImage
                    .resizable()
                    .scaledToFill()

                VStack(alignment: .leading) {
                    // 상단 칩
                    HStack(spacing: 4) {
                        chipView(text: solarTermIntro.term.koreanName)
                        if let dateLabel {
                            chipView(text: dateLabel)
                        }
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

                        Text(solarTermIntro.introSubtitle)
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
    SolarTermIntroCardView(solarTermIntro: .mock, season: .summer, dateLabel: "05.05 - 05.20", onTap: {})
        .frame(width: 266, height: 400)
        .padding()
}
