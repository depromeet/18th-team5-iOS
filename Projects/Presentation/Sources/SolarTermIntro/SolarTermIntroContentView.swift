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
        VStack(spacing: 0) {
            navigationBar
            ScrollView {
                VStack(spacing: 24) {
                    introHeaderSection
                    contentIntroSection
                    contentListSection
                    BottomButton(title: "미션으로 이동") {
                        store.send(.onMissionTap)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 11)
                .padding(.bottom, 16)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .background(Color.gray50)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Header

private extension SolarTermIntroContentView {
    var navigationBar: some View {
        ZStack {
            Text("\(store.solarTermIntro.term.koreanName) 소개보기")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)

            HStack {
                backButton
                Spacer()
            }
            .padding(.leading, 20)
        }
        .frame(height: 56)
    }

    var backButton: some View {
        Button {
            store.send(.onTapBack)
        } label: {
            Image.icArrowLeft
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

private extension SolarTermIntroContentView {
    var introHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(store.solarTermIntro.title)
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 4) {
                solarTermLabel(label: store.solarTermIntro.term.koreanName)

                Text(store.dateLabel)
                    .foregroundStyle(Color.white)
                    .font(.body1Semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: .radius16)
                    .fill(
                        LinearGradient(
                            colors: [
                                store.season.color(.scale100),
                                store.season.color(.scale300)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )

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
                .foregroundStyle(Color.gray600)

            if content.imageURLs.count > 1 {
                AutoScrollImageView(imageNames: content.imageURLs)
            } else if let imageName = content.imageURLs.first {
                Image(imageName, bundle: DesignSystemResources.bundle)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: .radius16))
            }

            Text(content.body)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
        }
    }
}

// MARK: - Auto Scroll Image

private struct AutoScrollImageView: View {
    let imageNames: [String]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(imageNames.enumerated()), id: \.offset) { index, imageName in
                Image(imageName, bundle: DesignSystemResources.bundle)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity)
        .aspectRatio(1.44, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % imageNames.count
            }
        }
        .overlay(alignment: .bottom) {
            ImageIndicator(count: imageNames.count, current: currentIndex)
                .padding(.bottom, 6)
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
