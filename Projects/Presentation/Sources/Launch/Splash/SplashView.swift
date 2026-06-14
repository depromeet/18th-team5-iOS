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
        .customAlert(store.scope(state: \.alert, action: \.alert))
    }
}

extension SplashFeature.Alert: AlertPresentable {
    public var alertInfo: AlertInfo {
        switch self {
        case .error:
            AlertInfo(
                icon: .icWarning,
                title: "문제가 발생했어요\nWiFi 또는 모바일 네트워크\n연결 상태를 확인해주세요",
                buttonTitle: "확인"
            )
        }
    }
}
