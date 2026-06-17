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

// MARK: - 공용 칩 뷰

private struct SolarTermChipView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.body2Medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(Color.blackAlpha300)
            }
            .background {
                CustomBackdropBlurView(radius: 10)
                    .clipShape(Capsule())
            }
    }
}

// MARK: - 일반 절기 카드

struct SolarTermIntroCardView: View {
    let solarTermIntro: SolarTermIntro
    let season: Season
    let dateLabel: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    SolarTermChipView(text: solarTermIntro.term.koreanName)
                    if let dateLabel {
                        SolarTermChipView(text: dateLabel)
                    }
                }
                .padding(.top, 18)
                .padding(.leading, 20)

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text(solarTermIntro.introTitle)
                        .font(.title2Bold)
                        .foregroundStyle(season.color(.scale700))
                        .lineLimit(3)

                    Text(solarTermIntro.introSubtitle)
                        .font(.body2Semibold)
                        .foregroundStyle(season.color(.scale500))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 23)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                solarTermIntro.term.solarTermCardImage
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: .radius20))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 현재 절기 카드 (실사 이미지 + 그라데이션)

struct CurrentSolarTermCardView: View {
    let solarTermIntro: SolarTermIntro
    let season: Season
    let dateLabel: String?
    let cardImageURL: URL?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack {
                // 칩 - 절기날짜, 절기명
                HStack(spacing: 4) {
                    SolarTermChipView(text: solarTermIntro.term.koreanName)
                    if let dateLabel {
                        SolarTermChipView(text: dateLabel)
                    }
                    Spacer()
                }
                .padding(.top, 18)
                .padding(.leading, 20)

                Spacer()

                // 하단 텍스트
                VStack(alignment: .leading, spacing: 8) {
                    Text(solarTermIntro.introTitle)
                        .font(.title2Bold)
                        .foregroundStyle(season.color(.scale700))
                        .lineLimit(3)

                    Text(solarTermIntro.introSubtitle)
                        .font(.body2Semibold)
                        .foregroundStyle(season.color(.scale500))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 23)
            }
            .background {
                // 실사 이미지 (그라데이션 배경 뒤)
                if let cardImageURL {
                    GeometryReader { geo in
                        RemoteImage(url: cardImageURL)
                            .frame(width: geo.size.width, height: geo.size.height * 0.83)
                            .clipped()
                            .mask(
                                LinearGradient(
                                    colors: [.black, .black, .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
            }
            .background {
                // 그라데이션 배경
                Image.imgSolarTermGradation
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: .radius20))
        }
        .buttonStyle(.plain)
    }
}

#Preview("일반 절기") {
    SolarTermIntroCardView(solarTermIntro: .mock, season: .summer, dateLabel: "05.05 - 05.20", onTap: {})
        .frame(width: 266, height: 400)
        .padding()
}

#Preview("현재 절기") {
    CurrentSolarTermCardView(
        solarTermIntro: .mock,
        season: .summer,
        dateLabel: "05.05 - 05.20",
        cardImageURL: URL(string: "https://picsum.photos/400/300"),
        onTap: {}
    )
    .frame(width: 266, height: 400)
    .padding()
}
