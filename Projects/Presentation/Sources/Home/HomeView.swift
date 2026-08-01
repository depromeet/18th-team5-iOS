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
                .padding(.top, 72)
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
        .background(LinearGradient.homeBackground(store.solarTerm.season.color(.scale50)).ignoresSafeArea())
        .overlay(alignment: .top) {
            HomeHeaderView(
                showBlur: scrollOffset > 1,
                myPageAction: { store.send(.myPageButtonTapped) }
            )
        }
        .customAlert(store.scope(state: \.alert, action: \.alert))
        .onAppear { store.send(.onAppear) }
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading {
            loadingView
        } else if let homeCard = store.homeCard {
            loadedView(for: homeCard)
        }
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
    }

    private func loadedView(for homeCard: HomeCard) -> some View {
        VStack(spacing: 16) {
            SolarTermCardView(
                card: homeCard.solarTerm,
                solarTerm: store.solarTerm,
                mission: homeCard.currentMission,
                onMissionTap: { store.send(.onMissionTap) },
                onDetailTap: { store.send(.onSolarTermDetailTap) }
            )

            MissionRecommendBannerView(
                onTap: { store.send(.onMissionRecommendTap) }
            )

            if let seasonRecord = store.seasonRecord {
                SeasonRecordSectionView(
                    seasonRecord: seasonRecord,
                    season: store.solarTerm.season,
                    onDetailTap: { store.send(.calendarButtonTapped) },
                    onPhotoTap: { dateString in store.send(.onRecordPhotoTap(dateString)) }
                )
            }
        }
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
            $0.homeRepository.fetchCard = { throw URLError(.notConnectedToInternet) }
        }
    )
}
