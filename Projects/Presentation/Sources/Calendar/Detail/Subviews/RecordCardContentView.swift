//
//  RecordCardContentView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

/// 카드 스택 최상단(내용) 카드 뷰.
///
/// 시각 표현은 `RecordCardBody`(저장·공유 경로와 공유)에 위임하고, 이 뷰는 화면에서만 필요한
/// 인터랙션 요소(카운트 배지·메뉴)를 overlay로 얹습니다.
///
/// CardStackView는 드래그 한 틱마다 body를 재평가하므로, 카드 내용이 그대로일 때 본문을
/// 다시 빌드하면(특히 KFImage·그라데이션) 프레임 드랍이 발생합니다. `Equatable`로 입력이
/// 동일하면 body 재실행을 건너뛰고, 드래그 변환(offset/opacity/scale)은 이 뷰 바깥에서만
/// 적용되어 GPU에서 저렴하게 처리됩니다.
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
