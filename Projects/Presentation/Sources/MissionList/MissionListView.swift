//
//  MissionListView.swift
//  Presentation
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct MissionListView: View {
    @Bindable private var store: StoreOf<MissionListFeature>

    public init(store: StoreOf<MissionListFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.white
                .overlay { circleBackgroundView }
        }
        .overlay(alignment: .top) { headerView }
    }
}

private extension MissionListView {
    var headerView: some View {
        VStack(spacing: 20) {
            titleView

            HStack(spacing: 0) {
                categoryListView
                Spacer()
                selectMissionButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 12)
        .background { headerBackgroundView }
        .overlay(alignment: .bottomTrailing) {
            tooltip
                .padding(.trailing, 20)
                .padding(.bottom, -38)
        }
    }

    var titleView: some View {
        VStack(spacing: 2) {
            Text("\(store.nickname)님을 위한")
                .font(.body1Regular)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(store.solarTerm.koreanName) 미션을 기록해볼까요?")
                .font(.headline1Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var categoryListView: some View {
        HStack(spacing: 6) {
            ForEach(MissionCategory.allCases, id: \.self) { category in
                categoryView(category)
            }
        }
    }

    func categoryView(_ category: MissionCategory) -> some View {
        Chip(
            title: category.name,
            type: category == store.category ? .default : .secondary,
            action: { store.send(.set(\.category, category)) }
        )
    }

    var selectMissionButton: some View {
        SelectMissionButton {
            store.send(.selectMissionButtonTapped)
        }
        .disabled(!store.isSelectMissionButtonEnabled)
    }

    var tooltip: some View {
        Tooltip(
            text: "기록하고 싶은 미션이 없다면?",
            position: .rightTop,
            isPresented: $store.isTooltipPresented
        )
    }

    var headerBackgroundView: some View {
        LinearGradient(
            stops: [
                .init(color: .white, location: 0.5),
                .init(color: .whiteAlpha100, location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(edges: .top)
    }

    var circleBackgroundView: some View {
        let width = UIScreen.width
        let diameter = width * 3 - 40

        return Color.gray50
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .offset(x: -width)
    }
}
