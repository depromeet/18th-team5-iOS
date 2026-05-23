//
//  MainView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct MainView: View {
    @Bindable private var store: StoreOf<MainFeature>

    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            TabView(selection: $store.tab) {
                ForEach(MainFeature.Tab.allCases, id: \.self) { tab in
                    tabView(tab: tab)
                        .tabItem { tabItem(tab: tab) }
                        .tag(tab)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(
                item: $store.scope(state: \.missionRecord, action: \.missionRecord)
            ) { missionRecordStore in
                MissionRecordView(store: missionRecordStore)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

private extension MainView {
    @ViewBuilder
    func tabView(tab: MainFeature.Tab) -> some View {
        switch tab {
        case .home:
            HomeView(store: store.scope(state: \.home, action: \.home))
        case .archive:
            Text("아카이빙")
        case .myPage:
            Text("마이페이지")
        }
    }

    @ViewBuilder
    func tabItem(tab: MainFeature.Tab) -> some View {
        tab.image
        Text(tab.title)
    }
}

private extension MainFeature.Tab {
    var image: Image {
        switch self {
        case .home: Image(systemName: "house")
        case .archive: Image(systemName: "folder")
        case .myPage: Image(systemName: "person")
        }
    }

    var title: String {
        switch self {
        case .home: "홈"
        case .archive: "아카이빙"
        case .myPage: "마이페이지"
        }
    }
}
