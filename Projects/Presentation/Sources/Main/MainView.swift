//
//  MainView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MainView: View {
    @Bindable private var store: StoreOf<MainFeature>

    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            TabView(selection: $store.tab) {
                ForEach(MainFeature.Tab.allCases, id: \.self) { tab in
                    tabView(tab: tab)
                        .tag(tab)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .overlay(alignment: .bottom) {
                if store.tabBarVisibility {
                    tabBar
                }
            }
            .navigationBarHidden(true)
            .customAlert(store.scope(state: \.alert, action: \.alert))
        } destination: { store in
            pathView(store: store)
        }
        .toastContainer()
        .onAppear { store.send(.onAppear) }
    }
}

private extension MainView {
    @ViewBuilder
    func tabView(tab: MainFeature.Tab) -> some View {
        switch tab {
        case .home:
            HomeView(store: store.scope(state: \.home, action: \.home))
        case .solarTerm:
            SolarTermIntroView(store: store.scope(state: \.solarTermIntro, action: \.solarTermIntro))
        case .mission:
            MissionListView(store: store.scope(state: \.mission, action: \.mission))
        case .calendar:
            CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
        default:
            Text(tab.title)
        }
    }

    var tabBar: some View {
        HStack(spacing: 6) {
            ForEach(MainFeature.Tab.allCases, id: \.self) { tab in
                Button {
                    store.send(.set(\.tab, tab))
                } label: {
                    tabItemView(tab)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.blackAlpha300, radius: 15, x: 0, y: 2)
        .overlay(Capsule().stroke(Color.blackAlpha200))
        .padding(.horizontal, 20)
    }

    func tabItemView(_ tab: MainFeature.Tab) -> some View {
        VStack(spacing: 4) {
            let color: Color = tab == store.tab ? .gray900 : .gray500

            tab.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(color)

            Text(tab.title)
                .font(.caption2Medium)
                .foregroundStyle(color)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 64)
    }
}

private extension MainFeature.Tab {
    var image: Image {
        switch self {
        case .home: .icHomeTab
        case .solarTerm: .icFileTab
        case .mission: .icMailTab
        case .calendar: .icCalendarTab
        }
    }

    var title: String {
        switch self {
        case .home: "홈"
        case .solarTerm: "절기소개"
        case .mission: "미션"
        case .calendar: "캘린더"
        }
    }
}

extension MainFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case let .mission(alert): alert.alertInfo
        }
    }
}
