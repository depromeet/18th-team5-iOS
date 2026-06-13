//
//  CalendarDetailView+Card.swift
//  Presentation
//
//  Created by choijunios on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Kingfisher
import SwiftUI

extension CalendarDetailView {
    private enum Constants {
        static let cardHorizontalPadding: CGFloat = 32.5

        /// Figma 카드 기준 치수 (3868:21604)
        static let cardRatio: CGFloat = cardBaseHeight / cardBaseWidth
        static let cardBaseWidth: CGFloat = 311
        static let cardBaseHeight: CGFloat = 391
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

    enum CardType {
        case content(cardIndex: Int, DateCard)
        case placeholder(orderIndex: Int)
    }

    var cardWidth: CGFloat {
        max(screenSize.width - Constants.cardHorizontalPadding * 2, 0)
    }

    func cardView(
        cardIndex: Int,
        orderIndex: Int,
        card: DateRecordCard
    ) -> some View {
        Group {
            if orderIndex == 0 {
                contentsCardView(index: cardIndex, card: card)
            } else {
                RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                    .foregroundStyle(
                        orderIndex <= 1 ? Color.gray200 : Color.gray50
                    )
            }
        }
        .frame(
            width: cardWidth,
            height: cardWidth * Constants.cardRatio
        )
    }

    private func cardBackgroundGradient(cardWidth: CGFloat) -> RadialGradient {
        RadialGradient(
            gradient: Gradient(stops: Constants.cardGradientStops),
            center: Constants.cardGradientCenter,
            startRadius: 0,
            endRadius: cardWidth * Constants.cardGradientRadiusRatio
        )
    }

    private func contentsCardView(index: Int, card: DateRecordCard) -> some View {
        ZStack {
            cardBackground(cardWidth)

            VStack {
                cardImageView(card.imageURL)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.horizontal, 48)
                    .padding(.top, 43.5)

                Spacer()
            }

            VStack(spacing: 12) {
                Spacer()

                Text(card.missionTitle ?? "-")
                    .font(.headline1Semibold)
                    .foregroundStyle(.white)

                Text(card.memo ?? "-")
                    .font(.body2Medium)
                    .foregroundStyle(.white)
                    .underline(true, pattern: .solid, color: .white)
                    .frame(minHeight: 52, alignment: .top)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)

            cardToolbarView(index)
        }
    }

    private var cardImagePlaceholder: some View {
        Rectangle().fill(Color.gray300)
    }

    private func cardImageView(_ url: URL?) -> some View {
        cardImagePlaceholder
            .aspectRatio(1.0, contentMode: .fit)
            .overlay {
                if let url {
                    KFImage(url)
                        .placeholder { cardImagePlaceholder }
                        .cacheOriginalImage()
                        .scaleFactor(UIScreen.main.scale)
                        .fade(duration: 0.2)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white, lineWidth: 3)
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

    private var imageHorSticker: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 16, height: 6)
    }

    private var imageVerSticker: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 6, height: 16)
    }

    private func cardBackground(_ cardWidth: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
            .fill(cardBackgroundGradient(cardWidth: cardWidth))
    }

    private func cardToolbarView(_ cardIndex: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                CardCountBadge(
                    current: cardIndex + 1,
                    total: store.dateRecordCards.count
                )

                Spacer()

                Image.icMenu
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray800)
                    .frame(width: 30, height: 30)
                    .contextMenus(verticalSpacing: 12) { dismiss in
                        cardMenuItem(title: "삭제하기", icon: .icTrash) {
                            store.send(.removeCardButtonTapped)
                            dismiss()
                        }
                        cardMenuItem(title: "수정하기", icon: .icEdit) {
                            // TODO: 액션 전송, 수정하기 버튼의 경우 현재 절기인 경우만 노출 -@준영
                            dismiss()
                        }
                    }
            }
            Spacer()
        }
        .padding([.top, .horizontal], 16)
    }

    private func cardMenuItem(
        title: String,
        icon: Image,
        onTap: @escaping () -> Void
    ) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 6) {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray900)
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray900)
            }
        }
    }
}
