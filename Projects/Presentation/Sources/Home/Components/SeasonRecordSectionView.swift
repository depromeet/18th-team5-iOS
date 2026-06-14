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
    let season: Season
    let onDetailTap: () -> Void
    let onPhotoTap: (String) -> Void

    var body: some View {
        VStack(spacing: 12) {
            // 헤더
            HStack {
                Text("\(seasonRecord.solarTermName)에 포착한 기록들이에요")
                    .font(.body1Semibold)
                    .foregroundStyle(Color.gray900)

                Spacer()

                Button(action: onDetailTap) {
                    HStack(spacing: 0) {
                        Text("더보기")
                            .font(.body2Medium)
                            .foregroundStyle(Color.gray600)
                        Image.icArrowRight
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.gray600)
                    }
                }
            }

            // 제철 기록 사진
            VStack(spacing: 0) {
                switch seasonRecord.photoURL.count {
                case 0:
                    EmptyPhotoView()
                        .padding(.bottom, 20)
                case 1:
                    OnePhotoView(records: seasonRecord.recentRecords, onPhotoTap: onPhotoTap)
                        .padding(.bottom, 16)
                case 2:
                    TwoPhotoView(records: seasonRecord.recentRecords, onPhotoTap: onPhotoTap)
                        .aspectRatio(335.0 / 176.0, contentMode: .fit)
                        .padding(.bottom, 40)
                default:
                    ThreePhotoView(records: seasonRecord.recentRecords, onPhotoTap: onPhotoTap)
                        .aspectRatio(335.0 / 172.0, contentMode: .fit)
                        .padding(.bottom, 40)
                }
                PhotoCountView(count: seasonRecord.recordCount, season: season)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
    }
}

// MARK: - 기록 횟수 텍스트

private struct PhotoCountView: View {
    let count: Int
    let season: Season

    var body: some View {
        switch count {
        case 0:
            Text("제철 기록을 남기지 않았어요")
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
                .padding(.top, 20)
        default:
            HStack(spacing: 0) {
                Text("총 ")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)
                Text("\(count)번")
                    .font(.body2Semibold)
                    .foregroundStyle(season.color(.scale600))
                Text("의 순간을 포착했어요!")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray600)
            }
        }
    }
}

// MARK: - 공통 사진 아이템

private struct PhotoItem: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        Group {
            if let url {
                RemoteImage(url: url)
            } else {
                RoundedRectangle(cornerRadius: .radius16)
                    .fill(Color(hex: 0xDCDEE3))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
        .overlay(
            RoundedRectangle(cornerRadius: .radius16)
                .stroke(Color.white, lineWidth: 2)
        )
    }
}

// MARK: - 사진 0장

private struct EmptyPhotoView: View {
    var body: some View {
        Image.imgEmptyRecord
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

// MARK: - 사진 1장

private struct OnePhotoView: View {
    let records: [RecentRecord]
    let onPhotoTap: (String) -> Void

    var body: some View {
        GeometryReader { geo in
            RemoteImage(url: records[safe: 0]?.imageURL, contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.width * 9 / 16)
                .clipShape(RoundedRectangle(cornerRadius: .radius16))
                .onTapGesture { onPhotoTap(records[safe: 0]?.recordedAt ?? "") }
        }
        .aspectRatio(16.0 / 9.0, contentMode: .fit)
    }
}

// MARK: - 사진 2장

private struct TwoPhotoView: View {
    let records: [RecentRecord]
    let onPhotoTap: (String) -> Void

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // 오른쪽 사진 (컨테이너 303x176)
                PhotoItem(url: records[safe: 1]?.imageURL, size: w * 144 / 303)
                    .position(x: w * 231 / 303, y: h * 104 / 176)
                    .onTapGesture { onPhotoTap(records[safe: 1]?.recordedAt ?? "") }

                // 왼쪽 큰 사진
                PhotoItem(url: records[safe: 0]?.imageURL, size: w * 160 / 303)
                    .rotationEffect(.degrees(-6))
                    .position(x: w * 88 / 303, y: h * 88 / 176)
                    .onTapGesture { onPhotoTap(records[safe: 0]?.recordedAt ?? "") }
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - 사진 3장 이상

private struct ThreePhotoView: View {
    let records: [RecentRecord]
    let onPhotoTap: (String) -> Void

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // 오른쪽 사진
                PhotoItem(url: records[safe: 2]?.imageURL, size: w * 126 / 303)
                    .rotationEffect(.degrees(4))
                    .position(x: w * 231 / 303, y: h * 82 / 172)
                    .onTapGesture { onPhotoTap(records[safe: 2]?.recordedAt ?? "") }

                // 가운데 하단 사진
                PhotoItem(url: records[safe: 1]?.imageURL, size: w * 100 / 303)
                    .rotationEffect(.degrees(2))
                    .position(x: w * 166 / 303, y: h * 122 / 172)
                    .onTapGesture { onPhotoTap(records[safe: 1]?.recordedAt ?? "") }

                // 왼쪽 큰 사진
                PhotoItem(url: records[safe: 0]?.imageURL, size: w * 144 / 303)
                    .rotationEffect(.degrees(-6))
                    .position(x: w * 79 / 303, y: h * 79 / 172)
                    .onTapGesture { onPhotoTap(records[safe: 0]?.recordedAt ?? "") }
            }
            .padding(.top, 12)
        }
    }
}

#Preview("사진 0개") {
    SeasonRecordSectionView(
        seasonRecord: SeasonRecord(solarTermName: "하지", recentRecords: [], recordCount: 0),
        season: .summer,
        onDetailTap: {},
        onPhotoTap: { _ in }
    )
    .padding()
}

#Preview("사진 1개") {
    SeasonRecordSectionView(
        seasonRecord: SeasonRecord(
            solarTermName: "하지",
            recentRecords: [
                RecentRecord(imageURL: URL(string: "https://picsum.photos/seed/a/300/300")!, recordedAt: "2026-06-14")
            ],
            recordCount: 1
        ),
        season: .summer,
        onDetailTap: {},
        onPhotoTap: { _ in }
    )
    .padding()
}

#Preview("사진 2개") {
    SeasonRecordSectionView(
        seasonRecord: SeasonRecord(
            solarTermName: "하지",
            recentRecords: [
                RecentRecord(imageURL: URL(string: "https://picsum.photos/seed/a/300/300")!, recordedAt: "2026-06-14"),
                RecentRecord(imageURL: URL(string: "https://picsum.photos/seed/b/300/300")!, recordedAt: "2026-06-13")
            ],
            recordCount: 2
        ),
        season: .summer,
        onDetailTap: {},
        onPhotoTap: { _ in }
    )
    .padding()
}

#Preview("사진 3개") {
    SeasonRecordSectionView(
        seasonRecord: .mock,
        season: .summer,
        onDetailTap: {},
        onPhotoTap: { _ in }
    )
    .padding()
}
