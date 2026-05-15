//
//  SeasonRecordSectionView.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct SeasonRecordSectionView: View {
    let seasonRecord: SeasonRecord
    let onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더
            HStack {
                Text("제철 기록이에요")
                    .font(.headline2Semibold)
                    .foregroundStyle(Color.gray900)

                Spacer()

                Button(action: onDetailTap) {
                    HStack(spacing: 0) {
                        Text("자세히 보기 ")
                            .font(.body2Medium)
                            .foregroundStyle(Color.gray600)
                        Image.icArrowRight
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }

            // 제철 기록 사진
            PhotoCollageView(photoURLs: seasonRecord.photoURL)
                .aspectRatio(335.0 / 192.0, contentMode: .fit)

            // 기록 횟수 배지
            HStack(spacing: 4) {
                Text("이번 절기에")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)
                Text("\(seasonRecord.recordCount)번")
                    .font(.body2Medium)
                    .foregroundStyle(Color(hex: 0x494949))
                Text("기록했어요")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.gray100)
            .clipShape(RoundedRectangle(cornerRadius: .radius12))
        }
    }
}

private struct PhotoCollageView: View {
    let photoURLs: [URL]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack {
                // 왼쪽 큰 사진 (회전 -6°)
                photoItem(index: 0, size: w * 0.4776)
                    .rotationEffect(.degrees(-6))
                    .position(x: w * 0.2625, y: w * 0.2625)

                // 오른쪽 사진 (회전 4°, 오른쪽 정렬)
                photoItem(index: 1, size: w * 0.4179)
                    .rotationEffect(.degrees(4))
                    .position(x: w * 0.7761, y: w * 0.2828)

                // 가운데 사진 (회전 2°)
                photoItem(index: 2, size: w * 0.3343)
                    .rotationEffect(.degrees(2))
                    .position(x: w * 0.5490, y: w * 0.3989)
            }
        }
    }

    private func photoItem(index: Int, size: CGFloat) -> some View {
        Group {
            if index < photoURLs.count {
                AsyncImage(url: photoURLs[index]) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    photoPlaceholder
                }
            } else {
                photoPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
        .overlay(
            RoundedRectangle(cornerRadius: .radius16)
                .stroke(Color.white, lineWidth: 2)
        )
    }

    private var photoPlaceholder: some View {
        RoundedRectangle(cornerRadius: .radius16)
            .fill(Color(hex: 0xDCDEE3))
    }
}

#Preview("사진 있음") {
    SeasonRecordSectionView(
        seasonRecord: SeasonRecord(
            photoURL: [
                URL(string: "https://picsum.photos/seed/a/300/300")!,
                URL(string: "https://picsum.photos/seed/b/300/300")!,
                URL(string: "https://picsum.photos/seed/c/300/300")!
            ],
            recordCount: 15
        ),
        onDetailTap: {}
    )
    .padding()
}

#Preview("사진 없음") {
    SeasonRecordSectionView(
        seasonRecord: SeasonRecord(photoURL: [], recordCount: 0),
        onDetailTap: {}
    )
    .padding()
}
