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

            pickerView
                .animation(.easeInOut(duration: 0.25), value: store.selectedMission)
                .allowsHitTesting(!store.isIndicatorEnabled)
                .overlay(alignment: .trailing) { indicatorView }
        }
        .overlay(alignment: .top) { headerView }
        .onAppear { store.send(.onAppear) }
        .loading(isLoading: store.isLoading)
        .sheet(item: $store.scope(state: \.search, action: \.search)) { store in
            MissionSearchView(store: store)
        }
        .fullScreenCover(
            item: $store.scope(state: \.searchResult, action: \.searchResult)
        ) { store in
            MissionSearchResultView(store: store)
        }
    }
}

private extension MissionListView {
    var headerView: some View {
        VStack(spacing: 20) {
            titleView

            HStack(spacing: 0) {
                themeListView
                Spacer()
                searchMissionButton
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
        .renderedIf(store.solarTerm != nil)
    }

    @ViewBuilder
    var titleView: some View {
        if let userName = store.userType?.name,
           let solaTermName = store.solarTerm?.koreanName {
            VStack(spacing: 2) {
                Text("\(userName)님을 위한")
                    .font(.body1Regular)
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(solaTermName) 미션을 기록해볼까요?")
                    .font(.headline1Semibold)
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    var themeListView: some View {
        HStack(spacing: 6) {
            ForEach(MissionTheme.allCases, id: \.self) { theme in
                themeView(theme)
            }
        }
    }

    func themeView(_ theme: MissionTheme) -> some View {
        Chip(
            title: theme.name,
            type: theme == store.theme ? .default : .secondary,
            action: { store.send(.themeTapped(theme)) }
        )
    }

    var searchMissionButton: some View {
        SearchMissionButton {
            store.send(.searchMissionButtonTapped)
        }
        .disabled(!store.isSearchMissionButtonEnabled)
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

    @ViewBuilder
    var pickerView: some View {
        if let selection = Binding($store.selectedMission) {
            CircularWheelPicker(
                items: store.missions,
                selection: selection,
                content: missionCardView
            )
        }
    }

    @ViewBuilder
    func missionCardView(_ mission: Mission) -> some View {
        if let season = store.season {
            PickerMissionCardView(
                mission: mission,
                season: season,
                isActive: store.selectedMission == mission,
                action: {}
            )
            .padding(.leading, 20)
            .padding(.trailing, 58)
        }
    }

    @ViewBuilder
    var indicatorView: some View {
        if let selectedIndex = store.selectedIndex,
           let season = store.season {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height

                Indicator(
                    totalCount: store.missions.count,
                    selectedIndex: selectedIndex,
                    mainColor: season.color(.scale500),
                    isEnabled: $store.isIndicatorEnabled,
                    indexChanged: { store.send(.indicatorIndexChanged($0)) }
                )
                .padding(.trailing, 20)
                .frame(width: width, height: height, alignment: .topTrailing)
                .padding(.top, height / 2 + 52)
            }
        }
    }
}
