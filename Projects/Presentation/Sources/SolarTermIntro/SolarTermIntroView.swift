//
//  SolarTermIntroView.swift
//  Presentation
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct SolarTermIntroView: View {
    @Bindable private var store: StoreOf<SolarTermIntroFeature>

    init(store: StoreOf<SolarTermIntroFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            bodySection
            cardCarousel
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { store.send(.onAppear) }
        .navigationDestination(
            item: $store.scope(state: \.content, action: \.content)
        ) { contentStore in
            SolarTermIntroContentView(store: contentStore)
        }
    }
}

// MARK: - Subviews

private extension SolarTermIntroView {
    var navigationBar: some View {
        Text("절기 소개")
            .font(.body1Medium)
            .foregroundStyle(Color.gray900)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
    }

    var bodySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Peaktime이 소개하는\n24절기 제철 가이드")
                .font(.headline1Semibold)
                .foregroundStyle(Color(hex: 0x2A3038))

            seasonChips
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 36)
    }

    var seasonChips: some View {
        HStack(spacing: 4) {
            ForEach(Season.allCases, id: \.self) { season in
                Chip(
                    title: season.displayName,
                    type: store.season == season ? .default : .secondary
                ) {
                    store.send(.selectSeason(season))
                }
            }
        }
    }

    var cardCarousel: some View {
        Carousel(
            items: store.filteredCards,
            spacing: 16,
            aspectRatio: 266.0 / 400.0,
            shrinkRatio: 280.0 / 400.0,
            scrollPosition: Binding(
                get: { store.filteredCards.first { $0.term == store.targetTerm } },
                set: { _ in }
            )
        ) { solarTerm in
            Group {
                if store.currentTerm == solarTerm.term {
                    CurrentSolarTermCardView(
                        solarTermIntro: solarTerm,
                        season: store.season,
                        dateLabel: store.dateLabels[solarTerm.term],
                        cardImageURL: store.currentCardImageURL,
                        onTap: { store.send(.onCardTap(solarTerm)) }
                    )
                } else {
                    SolarTermIntroCardView(
                        solarTermIntro: solarTerm,
                        season: store.season,
                        dateLabel: store.dateLabels[solarTerm.term],
                        onTap: { store.send(.onCardTap(solarTerm)) }
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SolarTermIntroView(
            store: Store(initialState: SolarTermIntroFeature.State()) {
                SolarTermIntroFeature()
            } withDependencies: {
                $0.solarTermIntroRepository = .previewValue
                $0.solarTermRepository = .previewValue
            }
        )
    }
}
