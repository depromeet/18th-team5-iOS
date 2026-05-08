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
        ZStack(alignment: .top) {
            background

            ScrollView {
                VStack(spacing: 24) {
                    Color.clear.frame(height: 103)

                    if store.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                    } else if let homeData = store.homeData {
                        if let solarTerm = homeData.solarTerm, let mission = homeData.currentMission {
                            SolarTermCardView(
                                solarTerm: solarTerm,
                                mission: mission,
                                onMissionTap: { store.send(.onMissionTap) },
                                onDetailTap: { store.send(.onMissionEntireTap) }
                            )
                        }

                        MissionRecommendBannerView(
                            onTap: { store.send(.onMissionRecommendTap) }
                        )

                        SeasonRecordSectionView(
                            seasonRecord: homeData.seasonRecord,
                            onDetailTap: { store.send(.onRecordTap) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)

            HomeHeaderView()
        }
        .ignoresSafeArea(edges: .top)
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
