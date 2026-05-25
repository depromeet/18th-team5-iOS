//
//  HomeView.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>
    @State private var scrollOffset: CGFloat = 0

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            content
                .padding(.top, 76)
                .padding(.horizontal, 20)
                .padding(.bottom, 117)
                .overlay(alignment: .top) {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetKey.self,
                            value: -geo.frame(in: .scrollView).origin.y
                        )
                    }
                    .frame(height: 0)
                }
        }
        .onPreferenceChange(ScrollOffsetKey.self) { newValue in
            scrollOffset = newValue
        }
        .scrollIndicators(.hidden)
        .background(background)
        .overlay(alignment: .top) { HomeHeaderView(scrollOffset: scrollOffset) }
        .onAppear { store.send(.onAppear) }
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading {
            loadingView
        } else if store.hasError {
            errorView
        } else if let homeCard = store.homeCard {
            loadedView(for: homeCard)
        }
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Text("데이터를 불러오지 못했어요")
                .font(.body1Regular)
                .foregroundStyle(Color.gray600)

            Button(action: { store.send(.onRetryTap) }) {
                Text("불러오기")
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray600)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func loadedView(for homeCard: HomeCard) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                SolarTermCardView(
                    solarTerm: homeCard.solarTerm,
                    mission: homeCard.currentMission,
                    onMissionTap: { store.send(.onMissionTap) },
                    onDetailTap: { store.send(.onSolarTermDetailTap) }
                )

                MissionRecommendBannerView(
                    onTap: { store.send(.onMissionRecommendTap) }
                )
            }

            SeasonRecordSectionView(
                seasonRecord: store.seasonRecord,
                // TODO: 계절 기록 자세히보기 이동 페이지 확정 후 연결 - @minkyo
                onDetailTap: {}
            )
        }
    }

    private var background: some View {
        LinearGradient.onboardingBackground
            .ignoresSafeArea()
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeRepository = .previewValue
        }
    )
}

#Preview("에러상태") {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeRepository.fetchCard = {
                throw URLError(.notConnectedToInternet)
            }
        }
    )
}
