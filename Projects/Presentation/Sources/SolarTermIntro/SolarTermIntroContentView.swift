//
//  SolarTermIntroContentView.swift
//  Presentation
//
//  Created by 송민교 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct SolarTermIntroContentView: View {
    let store: StoreOf<SolarTermIntroContentFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                contentIntroSection
                contentListSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 11)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        // TODO: - button 디자인 확정 후 수정 - @minkyo
        .safeAreaInset(edge: .bottom) {
            BottomButton(title: "확인") {
                store.send(.onTapBack)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
        }
        .navigationTitle("\(store.solarTermIntro.term.koreanName) 소개보기")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.gray50)
    }
}

// MARK: - Header

private extension SolarTermIntroContentView {
    // TODO: 계절별 이미지 추가되면 교체 - @minkyo
    private var solarTermIntroImage: Image {
        switch store.season {
        case .spring: .imgSummerSolarTermIntroContent
        case .summer: .imgSummerSolarTermIntroContent
        case .autumn: .imgSummerSolarTermIntroContent
        case .winter: .imgSummerSolarTermIntroContent
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(store.solarTermIntro.title)
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            solarTermIntroImage
                .resizable()
                .frame(maxWidth: .infinity)
                .overlay {
                    VStack(spacing: 4) {
                        solarTermLabel(label: store.solarTermIntro.term.koreanName)

                        Text(store.dateLabel)
                            .foregroundStyle(Color.white)
                            .font(.body1Semibold)
                    }
                    .padding(.vertical, 12)
                }

            // 의미 & 특징
            VStack(spacing: 8) {
                infoLabel(label: "의미", text: store.solarTermIntro.meaning)
                infoLabel(label: "특징", text: store.solarTermIntro.characteristic)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: .radius16)
                .fill(Color.white)
        )
    }

    func infoLabel(label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Text(label)
                .font(.body2Semibold)
                .foregroundStyle(Color.gray800)
                .padding(.horizontal, 17)
                .padding(.vertical, 5)
                .background(Color.gray100)
                .clipShape(Capsule())

            Text(text)
                .font(.body2Medium)
                .foregroundStyle(Color.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
        }
    }

    func solarTermLabel(label: String) -> some View {
        Text(label)
            .font(.body2Semibold)
            .foregroundStyle(Color.white)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: 0x111111).opacity(0.15))
            )
    }
}

// MARK: - Content Intro

private extension SolarTermIntroContentView {
    var contentIntroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.solarTermIntro.contentTitle)
                .font(.headline2Semibold)
                .foregroundStyle(Color.gray900)

            Text(store.solarTermIntro.contentBody)
                .font(.body2Regular)
                .foregroundStyle(Color.gray500)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: .radius16)
                        .fill(Color.white)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Content List

private extension SolarTermIntroContentView {
    var contentListSection: some View {
        VStack(spacing: 24) {
            ForEach(store.solarTermIntro.contents, id: \.id) { content in
                contentCard(content)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: .radius16)
                    .fill(Color.white)
            )
        }
    }

    func contentCard(_ content: SolarTermIntroContent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(content.title)
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)

            Text(content.subtitle)
                .font(.body2Medium)
                .foregroundStyle(Color.blackAlpha700)

            AsyncImage(url: URL(string: content.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray100
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: .radius12))

            Text(content.body)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
        }
    }
}

#Preview {
    NavigationStack {
        SolarTermIntroContentView(
            store: Store(initialState: SolarTermIntroContentFeature.State(
                solarTermIntro: .mock,
                dateLabel: "2025년 5월 5일 - 5월 21일"
            )) {
                SolarTermIntroContentFeature()
            }
        )
    }
}
