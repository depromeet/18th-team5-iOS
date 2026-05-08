//
//  SplashView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct SplashView: View {
    private let store: StoreOf<SplashFeature>

    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 20) {
            // TODO: 스플래시 로고/애니메이션 영역
            Text("스플래시 화면")
        }
        .onAppear { store.send(.onAppear) }
    }
}
