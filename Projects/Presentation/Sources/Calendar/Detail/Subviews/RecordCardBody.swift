//
//  RecordCardBody.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import Kingfisher
import SwiftUI
import UIKit

struct RecordCardBody: View {
    let term: SolarTerm
    let card: DateRecordCard
    let cardWidth: CGFloat
    let imageSource: CardImageSource

    var body: some View {
        ZStack {
            cardBackground

            VStack(spacing: .zero) {
                cardImageView
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.top, 48)
                    .padding(.horizontal, 48)

                VStack(spacing: 12) {
                    if card.cardType == .free {
                        tagContainer
                    } else if let title = card.missionTitle, !title.isEmpty {
                        Text(title)
                            .font(.headline1Semibold)
                            .foregroundStyle(.white)
                    }

                    if let memo = card.memo, !memo.isEmpty {
                        Text(memo)
                            .font(.body2Medium)
                            .multilineTextAlignment(.center)
                            .truncationMode(.tail)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .baselineOffset(5)
                            .underline(true, pattern: .solid, color: .white)
                            .frame(minHeight: 52, alignment: .top)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)

                Spacer(minLength: 0)
            }
        }
    }
}

/// 카드 사진 로딩 방식.
///
/// - `remote`: `KFImage`로 비동기 로딩. 화면 표시용.
/// - `decoded`: 미리 디코딩된 `UIImage`. `ImageRenderer`가 동기 합성해야 하는 저장·공유용
///   (`KFImage`는 렌더 시점에 로딩이 끝나지 않아 빈 이미지로 찍힘).
enum CardImageSource {
    case remote(URL?)
    case decoded(UIImage?)
}

// MARK: - Subviews

private extension RecordCardBody {
    var cardBackground: some View {
        RoundedRectangle(cornerRadius: RecordCardLayout.cardCornerRadius)
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: RecordCardLayout.cardGradientStops(term.season)),
                    center: RecordCardLayout.cardGradientCenter,
                    startRadius: 0,
                    endRadius: cardWidth * RecordCardLayout.cardGradientRadiusRatio
                )
            )
    }

    var cardImagePlaceholder: some View {
        Rectangle().fill(Color.gray300)
    }

    var cardImageView: some View {
        cardImagePlaceholder
            .aspectRatio(1.0, contentMode: .fit)
            .overlay { cardPhoto }
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

    @ViewBuilder
    var cardPhoto: some View {
        switch imageSource {
        case let .remote(url):
            let imageSide = max(cardWidth - 96, 1)
            KFImage(url)
                .placeholder { cardImagePlaceholder }
                .setProcessor(
                    DownsamplingImageProcessor(
                        size: CGSize(width: imageSide, height: imageSide)
                    )
                )
                .cacheMemoryOnly()
                .scaleFactor(UIScreen.main.scale)
                .fade(duration: 0.1)
                .resizable()
                .scaledToFill()

        case let .decoded(image):
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
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
}

private extension RecordCardBody {
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
