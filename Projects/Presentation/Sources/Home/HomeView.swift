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
            VStack(spacing: 24) {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                } else if store.hasError {
                    VStack(spacing: 12) {
                        Text("데이터를 불러오지 못했어요")
                            .font(.body1Regular)
                            .foregroundStyle(Color.gray600)
                        Button(action: {
                            store.send(.onRetryTap)
                        }) {
                            Text("불러오기")
                                .foregroundStyle(Color.gray600)
                                .font(.body2Medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else if let homeData = store.homeCard {
                    VStack(spacing: 12) {
                        SolarTermCardView(
                            solarTerm: homeData.solarTerm,
                            mission: homeData.currentMission,
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
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeHeaderView()
                .background(
                    Color(.clear)
                        .ignoresSafeArea(edges: .top)
                )
        }
        .background(background)
        .onAppear { store.send(.onAppear) }
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
