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

/// 카드의 시각 표현(배경·사진·미션 제목/태그·메모) 단일 정의.
///
/// 화면 표시(`RecordCardContentView`)와 이미지 저장·공유(`CardImageRenderer`)가 동일한 레이아웃을
/// 공유하도록 추출한 뷰입니다. 두 경로의 유일한 차이인 이미지 로딩 방식만 `CardImageSource`로
/// 분기하므로, 레이아웃을 바꾸면 양쪽이 자동으로 일치합니다. (인터랙션 요소인 툴바는
/// `RecordCardContentView`가 이 뷰 위에 overlay로만 얹습니다.)
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
            if let url {
                // 카드 이미지 영역 한 변(가로 패딩 48 * 2 제외)에 맞춰 다운샘플링하여
                // 대용량 presigned 이미지를 매 렌더마다 원본 크기로 합성하지 않도록 합니다.
                let imageSide = max(cardWidth - 96, 1)
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
