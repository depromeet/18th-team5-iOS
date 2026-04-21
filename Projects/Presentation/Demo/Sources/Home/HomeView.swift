//
//  HomeView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>

    init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                VStack {
                    Button("미션 확인하기") {
                        store.send(.innerPushButtonTapped)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            }
            .navigationTitle("홈")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.outerPushButtonTapped)
                    } label: {
                        Image(systemName: "bell")
                    }
                }
            }
        } destination: { store in
            switch store.case {
            case let .mission(store): MissionView(store: store)
            case let .notification(store): NotificationView(store: store)
            }
        }
    }
}
