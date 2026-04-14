//
//  SplashView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SplashView: View {
    private let store: StoreOf<SplashFeature>

    init(store: StoreOf<SplashFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("스플래시 화면")
            Text("\(store.timeLeft)초 후 이동")
        }
        .onAppear { store.send(.onAppear) }
    }
}
