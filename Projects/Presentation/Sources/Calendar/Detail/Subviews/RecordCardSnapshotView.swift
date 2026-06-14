//
//  RecordCardSnapshotView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI
import UIKit

/// 이미지 저장·공유용 카드 스냅샷 뷰.
///
/// 화면에 표시되는 `RecordCardContentView`와 동일한 비주얼(배경 그라데이션·사진·미션 제목·메모)을
/// 그리되, 메뉴/배지 같은 인터랙션 요소는 제외합니다. `ImageRenderer`로 동기 렌더링하기 위해
/// 사진은 `KFImage` 대신 이미 디코딩된 `UIImage`를 주입받습니다.
struct RecordCardSnapshotView: View {
    let card: DateRecordCard
    let photo: UIImage?
    let cardWidth: CGFloat

    var body: some View {
        ZStack {
            cardBackground

            VStack {
                cardImageView
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
        }
    }
}

// MARK: - Subviews

private extension RecordCardSnapshotView {
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
            .overlay {
                if let photo {
                    Image(uiImage: photo)
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
}
