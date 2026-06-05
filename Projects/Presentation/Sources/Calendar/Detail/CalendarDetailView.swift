//
//  CalendarDetailView.swift
//  Presentation
//
//  Created by choijunios on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct CalendarDetailView: View {
    enum Constants {
        static let cardHorizontalPadding: CGFloat = 32.5

        /// Figma 카드 기준 치수 (3868:21604)
        static let cardBaseWidth: CGFloat = 311
        static let cardBaseHeight: CGFloat = 391
        static let cardRatio: CGFloat = cardBaseHeight / cardBaseWidth
        static let cardCornerRadius: CGFloat = 20

        /// 카드 배경 radial gradient 파라미터 (카드 기준 치수 좌표계)
        static let cardGradientCenter = UnitPoint(x: 156 / cardBaseWidth, y: 133 / cardBaseHeight)
        static let cardGradientRadiusRatio: CGFloat = 273 / cardBaseWidth
        static let cardGradientStops: [Gradient.Stop] = [
            .init(color: Color(hex: 0xE8FFB9), location: 0),
            .init(color: Color(hex: 0xBBF4AF), location: 0.25),
            .init(color: Color(hex: 0x8FE8A6), location: 0.5),
            .init(color: Color(hex: 0x62DD9C), location: 0.75),
            .init(color: Color.green400, location: 1)
        ]
    }

    @State var frontCardIndex: Int = 0
    @State var screenSize: CGSize = .zero
    let cards: [DateCard] = Array(repeating: .init(), count: 10)

    var body: some View {
        GeometryReader { _ in
            ZStack {
                backgroundView
                    .onGeometryChange(
                        for: CGSize.self,
                        of: { $0.size }
                    ) { screenSize = $0 }

                VStack {
                    CardStackView(
                        topCardIndex: $frontCardIndex,
                        items: cards
                    ) { index, item in
                        let orderIndex = index - frontCardIndex
                        let cardWidth = max(screenSize.width - Constants.cardHorizontalPadding * 2, 0)

                        Group {
                            if orderIndex == 0 {
                                card(.content(cardIndex: index, item), cardWidth: cardWidth)
                            } else {
                                card(.placeholder(orderIndex: orderIndex), cardWidth: cardWidth)
                            }
                        }
                        .frame(
                            width: cardWidth,
                            height: cardWidth * Constants.cardRatio
                        )
                    }
                    .padding(.top, 16)
                    Spacer()
                }

                bottomButtonContainer
            }
        }
    }
}

// MARK: Card

private extension CalendarDetailView {
    enum CardType {
        case content(cardIndex: Int, DateCard)
        case placeholder(orderIndex: Int)
    }

    func cardBackgroundGradient(cardWidth: CGFloat) -> RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: Constants.cardGradientStops),
            center: Constants.cardGradientCenter,
            startRadius: 0,
            endRadius: cardWidth * Constants.cardGradientRadiusRatio
        )
    }

    @ViewBuilder
    func card(_ type: CardType, cardWidth: CGFloat) -> some View {
        switch type {
        case let .content(index, _):
            ZStack {
                cardBackground(cardWidth)

                VStack {
                    cardImageView
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(.horizontal, 48)
                        .padding(.top, 43.5)

                    Spacer()
                }

                VStack(spacing: 12) {
                    Spacer()

                    // 모델링 대상
                    Text("나만의 여름 음료 개발하기")
                        .font(.headline1Semibold)
                        .foregroundStyle(.white)

                    // 모델링 대상
                    Text("이번 입하에는 여름 음료를 만들어 먹었다. 너무 맛있어")
                        .font(.body2Medium)
                        .foregroundStyle(.white)
                        .underline(true, pattern: .solid, color: .white)
                        .frame(minHeight: 52, alignment: .top)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                cardToolbarView(index)
            }
        case let .placeholder(index):
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .foregroundStyle(index <= 1 ? Color.gray200 : Color.gray50)
        }
    }

    var cardImageView: some View {
        RoundedRectangle(cornerRadius: 12)
            .padding(3)
            .background {
                RoundedRectangle(cornerRadius: 9)
                    .fill(.white)
            }
            .padding(7)
            .overlay {
                ZStack {
                    VStack {
                        imageVerSticker
                        Spacer()
                        imageVerSticker
                    }

                    HStack {
                        imageHorSticker
                        Spacer()
                        imageHorSticker
                    }
                }
            }
    }

    var imageHorSticker: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 16, height: 6)
    }

    var imageVerSticker: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 6, height: 16)
    }

    func cardBackground(_ cardWidth: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
            .fill(cardBackgroundGradient(cardWidth: cardWidth))
    }

    func cardToolbarView(_ cardIndex: Int) -> some View {
        VStack(spacing: .zero) {
            HStack {
                CardCountBadge(current: cardIndex + 1, total: cards.count)
                Spacer()
                Button {} label: {
                    Image.icMenu
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.gray800)
                        .frame(width: 30, height: 30)
                }
            }
            Spacer()
        }
        .padding([.top, .horizontal], 16)
    }
}

// MARK: DetailView

private extension CalendarDetailView {
    var backgroundView: some View {
        Color.white
            .overlay {
                VStack {
                    LinearGradient(
                        colors: [
                            .black.opacity(0.05),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30)
                    Spacer()
                }
            }
            .ignoresSafeArea(.container, edges: [.bottom])
    }

    var bottomButtonContainer: some View {
        VStack(spacing: .zero) {
            Spacer()
            HStack(spacing: 8) {
                Button {
                    // TODO: 액션
                } label: {
                    Text("이미지 저장")
                }
                .buttonStyle(.master(.large))

                Button {
                    // TODO: 액션
                } label: {
                    Text("이미지 공유")
                }
                .buttonStyle(.master(.large))
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    CalendarDetailView()
}
