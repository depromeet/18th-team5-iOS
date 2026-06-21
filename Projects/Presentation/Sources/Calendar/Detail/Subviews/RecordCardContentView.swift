//
//  RecordCardContentView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct RecordCardContentView: View, Equatable {
    let term: SolarTerm
    let card: DateRecordCard
    let cardIndex: Int
    let totalCount: Int
    let cardWidth: CGFloat
    let onDeleteTapped: () -> Void
    let onEditTapped: () -> Void

    static func == (lhs: RecordCardContentView, rhs: RecordCardContentView) -> Bool {
        lhs.term == rhs.term &&
            lhs.card == rhs.card &&
            lhs.cardIndex == rhs.cardIndex &&
            lhs.totalCount == rhs.totalCount &&
            lhs.cardWidth == rhs.cardWidth
    }

    var body: some View {
        RecordCardBody(
            term: term,
            card: card,
            cardWidth: cardWidth,
            imageSource: .remote(card.imageURL)
        )
        .overlay { cardToolbarView }
    }
}

// MARK: - Subviews

private extension RecordCardContentView {
    var cardToolbarView: some View {
        VStack(spacing: 12) {
            HStack {
                if totalCount > 1 {
                    CardCountBadge(current: cardIndex + 1, total: totalCount)
                }

                Spacer()

                Image.icMenu
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray800)
                    .frame(width: 30, height: 30)
                    .contextMenus(verticalSpacing: 12) { dismiss in
                        cardMenuItem(title: "삭제하기", icon: .icTrash) {
                            onDeleteTapped()
                            dismiss()
                        }
                        cardMenuItem(title: "수정하기", icon: .icEdit) {
                            onEditTapped()
                            dismiss()
                        }
                    }
            }
            Spacer()
        }
        .padding([.top, .horizontal], 16)
    }

    func cardMenuItem(
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

// MARK: - Layout Constants

enum RecordCardLayout {
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
