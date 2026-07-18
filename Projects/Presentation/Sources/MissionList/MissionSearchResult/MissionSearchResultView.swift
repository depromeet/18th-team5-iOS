//
//  MissionSearchResultView.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct MissionSearchResultView: View {
    private let store: StoreOf<MissionSearchResultFeature>

    public init(store: StoreOf<MissionSearchResultFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 0) {
                headerView

                VStack(spacing: 16) {
                    titleView
                    cardView
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)

                switch store.isSearching {
                case true:
                    Spacer()
                        .frame(height: 56)
                case false:
                    bottomButton
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

private extension MissionSearchResultView {
    var title: String {
        switch store.isSearching {
        case true: "선택한 조건에 맞는\n제철 활동을 찾고 있어요!"
        case false: "선택한 조건에 맞는\n제철 활동을 찾았어요!"
        }
    }
}

private extension MissionSearchResultView {
    var backgroundView: some View {
        Color.gray50
            .ignoresSafeArea()
    }

    var headerView: some View {
        ZStack {
            Text("제철 미션 찾기")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 60)

            HStack {
                Spacer()

                Button {
                    store.send(.backButtonTapped)
                } label: {
                    Image.icClose
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray800)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
    }

    var titleView: some View {
        Text(title)
            .font(.headline2Semibold)
            .foregroundStyle(Color.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }

    var cardView: some View {
        Group {
            switch store.isSearching {
            case true: searchingView
            case false: resultView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 48)
        .padding(.bottom, 56)
        .background { cardBackgroundView }
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
        .shadow(color: Color.blackAlpha100, radius: 12, x: 0, y: -4)
    }

    var searchingView: some View {
        VStack(spacing: 8) {
            LoadingTextView()
            lottieView
        }
        .padding(.top, 102)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    var lottieView: some View {
        Color.pink
            .frame(width: 120, height: 120)
    }

    var resultView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 20) {
                textView

                Image.imgCameraWithSparkles
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            categoryListView
        }
    }

    var cardBackgroundView: some View {
        ZStack(alignment: .top) {
            Color.white

            Circle()
                .foregroundStyle(store.season.color(.scale50))
                .frame(width: 240, height: 240)
                .blur(radius: 60)
                .offset(y: -120)
        }
    }

    var textView: some View {
        VStack(spacing: 16) {
            Text("결과")
                .font(.body2Medium)
                .foregroundStyle(Color.white)
                .frame(height: 30)
                .padding(.horizontal, 12)
                .background(store.season.color(.scale600))
                .clipShape(Capsule())

            VStack(spacing: 8) {
                Text(store.mission?.title ?? "")
                    .font(.headline1Semibold)
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity)

                Text(store.mission?.description ?? "")
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray700)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    var categoryListView: some View {
        HStack(spacing: 8) {
            locationTypeView
            participantTypeView
            categoryView
        }
        .disabled(true)
    }

    @ViewBuilder
    var locationTypeView: some View {
        if let locationType = store.locationType {
            SearchCategoryChipView(
                title: locationType.name,
                image: locationType.image,
                season: store.season
            )
        }
    }

    @ViewBuilder
    var participantTypeView: some View {
        if let participationType = store.participationType {
            SearchCategoryChipView(
                title: participationType.name,
                image: participationType.image,
                season: store.season
            )
        }
    }

    @ViewBuilder
    var categoryView: some View {
        if let category = store.category {
            SearchCategoryChipView(
                title: category.name,
                image: category.image,
                season: store.season
            )
        }
    }

    var bottomButton: some View {
        BottomButton(title: "미션 기록하기") {
            store.send(.bottomButtonTapped)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

private struct LoadingTextView: View {
    @State private var index: Int = 0
    @State private var textRotationTask: Task<Void, Never>?
    private let words: [String] = ["공간", "인원", "카테고리"]

    var body: some View {
        Text("원하는 \(words[index])에 맞는 미션 찾는 중...")
            .font(.body2Regular)
            .foregroundStyle(Color.gray700)
            .frame(maxWidth: .infinity)
            .onAppear {
                textRotationTask?.cancel()
                textRotationTask = Task {
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(1.4))
                        guard !Task.isCancelled else { return }
                        withAnimation(.easeOut(duration: 0.25)) {
                            index = (index + 1) % words.count
                        }
                    }
                }
            }
            .onDisappear {
                textRotationTask?.cancel()
                textRotationTask = nil
            }
    }
}
