//
//  SplashView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct SplashView: View {
    private let store: StoreOf<SplashFeature>

    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.gray800
                .ignoresSafeArea()

            Image.imgPeaktimeSplashLogo
                .resizable()
                .frame(width: 270, height: 48)
                .opacity(store.isLogoPresented ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.7), value: store.isLogoPresented)
        }
        .loading(isLoading: store.isLoading)
        .onAppear { store.send(.onAppear) }
    }
}
