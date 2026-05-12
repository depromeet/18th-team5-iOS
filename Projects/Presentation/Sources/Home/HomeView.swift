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

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            content
                .padding(.top, 76)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(background)
        .overlay(alignment: .top) { HomeHeaderView() }
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
                    onMissionTap: { store.send(.onMissionTap) }
                )

                MissionRecommendBannerView(
                    onTap: { store.send(.onMissionRecommendTap) }
                )
            }

            SeasonRecordSectionView(
                seasonRecord: store.seasonRecord,
                onDetailTap: { store.send(.onRecordTap) }
            )
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(hex: 0xECFBF3), .white],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
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
