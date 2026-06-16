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
                VStack(spacing: 12) {
                    if let intro = store.solarTermIntro {
                        introHeaderSection(intro)
                        contentIntroSection(intro)
                        contentListSection(intro)
                        if store.isCurrentTerm {
                            BottomButton(title: "미션으로 이동") {
                                store.send(.onMissionTap)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 11)
                .padding(.bottom, 16)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .swipeBackEnabled(isEnabled: !store.isLoading)
        .loading(isLoading: store.isLoading)
        .onAppear { store.send(.onAppear) }
        .background(Color.gray50)
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Header

private extension SolarTermIntroContentView {
    var navigationBar: some View {
        ZStack {
            Text("\(store.term.koreanName) 소개보기")
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
    func introHeaderSection(_ intro: SolarTermIntro) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(intro.title)
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 4) {
                solarTermLabel(label: intro.term.koreanName)

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
                infoLabel(label: "의미", text: intro.meaning)
                infoLabel(label: "특징", text: intro.characteristic)
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
                .foregroundStyle(Color.gray900)
                .padding(.horizontal, 17)
                .padding(.vertical, 5)
                .background(Color.gray200)
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
    func contentIntroSection(_ intro: SolarTermIntro) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(intro.contentTitle)
                .font(.headline2Semibold)
                .foregroundStyle(Color.gray900)

            Text(intro.contentBody)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
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
    func contentListSection(_ intro: SolarTermIntro) -> some View {
        VStack(spacing: 12) {
            ForEach(intro.contents, id: \.id) { content in
                contentCard(content)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: .radius16)
                    .fill(Color.white)
            )
        }
        .frame(maxWidth: .infinity)
    }

    /// 콘텐츠 카드 (제목 + 부제 + 이미지 + 본문)
    func contentCard(_ content: SolarTermIntroContent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                // 콘텐츠 제목
                Text(content.title)
                    .font(.headline1Semibold)
                    .foregroundStyle(Color.gray900)

                // 콘텐츠 부제
                Text(content.subtitle)
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray600)
            }

            // 이미지 영역 (Firebase Storage URL로 로딩)
            if let urls = store.imageURL[content.id], !urls.isEmpty {
                if urls.count > 1 {
                    AutoScrollImageView(imageURLs: urls) // 여러 장: 자동 스크롤 + 스와이프
                } else if let url = urls.first {
                    RemoteImage(url: url, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(303 / 210, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: .radius16))
                }
            }

            // 콘텐츠 본문
            Text(content.body)
                .font(.body2Regular)
                .foregroundStyle(Color.gray600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Auto Scroll Image (여러 장 이미지 자동 전환 + 스와이프 + 인디케이터)

private struct AutoScrollImageView: View {
    let imageURLs: [URL]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, url in
                RemoteImage(url: url)
                    .clipped()
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity)
        .aspectRatio(303 / 210, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % imageURLs.count
            }
        }
        .overlay(alignment: .bottom) {
            ImageIndicator(count: imageURLs.count, current: currentIndex)
                .padding(.bottom, 6)
        }
    }
}

#Preview {
    NavigationStack {
        SolarTermIntroContentView(
            store: Store(initialState: SolarTermIntroContentFeature.State(term: .ibha)) {
                SolarTermIntroContentFeature()
            }
        )
    }
}
