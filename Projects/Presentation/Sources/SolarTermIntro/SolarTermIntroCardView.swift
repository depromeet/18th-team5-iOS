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

// MARK: - 일반 절기 카드

struct SolarTermIntroCardView: View {
    let solarTermIntro: SolarTermIntro
    let season: Season
    let dateLabel: String?
    let onTap: () -> Void

    private var cardImage: Image {
        switch solarTermIntro.term {
        case .ibha: .imgIbhaSolarTermCard
        case .soman: .imgSomanSolarTermCard
        case .mangjong: .imgMangjongSolarTermCard
        case .haji: .imgHajiSolarTermCard
        case .soseo: .imgSoseoSolarTermCard
        case .daeseo: .imgDaeseoSolarTermCard
        default: .imgSolarTermCardDefault
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                cardImage
                    .resizable()
                    .scaledToFill()

                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        chipView(text: solarTermIntro.term.koreanName)
                        if let dateLabel {
                            chipView(text: dateLabel)
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
            .background {
                Color.black.opacity(0.15)
                    .blur(radius: 10)
            }
            .clipShape(Capsule())
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
            ZStack {
                // 1. 그라데이션 배경 + 하단 텍스트 (맨 뒤, 배경)
                Image.imgSolarTermGradation
                    .resizable()
                    .scaledToFill()
                    .overlay(alignment: .bottomLeading) {
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

                // 2. 실사 이미지 (Firebase Storage)
                if let cardImageURL {
                    GeometryReader { geo in
                        RemoteImage(url: cardImageURL)
                            .frame(width: geo.size.width, height: geo.size.height * 0.85)
                            .clipped()
                            .mask(
                                LinearGradient(
                                    colors: [.black, .black, .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .allowsHitTesting(false)
                }

                // 3. 칩 - 절기날짜, 절기명 (맨 앞, 이미지 위)
                VStack {
                    HStack(spacing: 4) {
                        chipView(text: solarTermIntro.term.koreanName)
                        if let dateLabel {
                            chipView(text: dateLabel)
                        }
                        Spacer()
                    }
                    .padding(.top, 18)
                    .padding(.leading, 20)
                    Spacer()
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
            .background {
                Color.black.opacity(0.15)
                    .blur(radius: 10)
            }
            .clipShape(Capsule())
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
