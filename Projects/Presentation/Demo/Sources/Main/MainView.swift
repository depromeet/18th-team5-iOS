//
//  MainView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    private let store: StoreOf<MainFeature>

    init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("메인 화면")

            Button("로그아웃") {
                store.send(.signOutButtonTapped)
            }
        }
    }
}
