//
//  RecordCardContentView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import Kingfisher
import SwiftUI

/// 카드 스택 최상단(내용) 카드 뷰.
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
        ZStack {
            cardBackground

            VStack {
                cardImageView(card.imageURL)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.horizontal, 48)
                    .padding(.top, 43.5)

                Spacer()
            }

            VStack(spacing: 12) {
                Spacer()

                if card.cardType == .free {
                    tagContainer
                } else {
                    Text(card.missionTitle ?? "-")
                        .font(.headline1Semibold)
                        .foregroundStyle(.white)
                }

                Text(card.memo ?? "-")
                    .font(.body2Medium)
                    .multilineTextAlignment(.center)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .underline(true, pattern: .solid, color: .white)
                    .frame(minHeight: 52, alignment: .top)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)

            cardToolbarView
        }
    }
}

// MARK: - Subviews

private extension RecordCardContentView {
    var cardBackground: some View {
        RoundedRectangle(cornerRadius: RecordCardLayout.cardCornerRadius)
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: RecordCardLayout.cardGradientStops),
                    center: RecordCardLayout.cardGradientCenter,
                    startRadius: 0,
                    endRadius: cardWidth * RecordCardLayout.cardGradientRadiusRatio
                )
            )
    }

    var cardImagePlaceholder: some View {
        Rectangle().fill(Color.gray300)
    }

    func cardImageView(_ url: URL?) -> some View {
        // 카드 이미지 영역 한 변(가로 패딩 48 * 2 제외)에 맞춰 다운샘플링하여
        // 대용량 presigned 이미지를 매 렌더마다 원본 크기로 합성하지 않도록 합니다.
        let imageSide = max(cardWidth - 96, 1)
        return cardImagePlaceholder
            .aspectRatio(1.0, contentMode: .fit)
            .overlay {
                if let url {
                    KFImage(url)
                        .placeholder { cardImagePlaceholder }
                        .setProcessor(
                            DownsamplingImageProcessor(
                                size: CGSize(width: imageSide, height: imageSide)
                            )
                        )
                        .scaleFactor(UIScreen.main.scale)
                        .cacheOriginalImage()
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

    var cardToolbarView: some View {
        VStack(spacing: 12) {
            HStack {
                CardCountBadge(current: cardIndex + 1, total: totalCount)

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

private extension RecordCardContentView {
    var tagContainer: some View {
        HStack(spacing: 4) {
            tagView(cardRecordText(card.recordedAt) ?? "-")
            tagView(term.koreanName)
        }
    }

    func tagView(_ text: String) -> some View {
        Text(text)
            .font(.body2Medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(height: 30, alignment: .center)
            .background {
                Capsule()
                    .fill(Color.blackAlpha300)
            }
    }

    func cardRecordText(_ date: Date) -> String? {
        Self.yyyyMMddFormatter.string(from: date)
    }

    static let yyyyMMddFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy. M.d"
        return formatter
    }()
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
