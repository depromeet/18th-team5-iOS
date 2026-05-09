//
//  DebugTokenSettingView.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct DebugTokenSettingView: View {
    @Bindable var store: StoreOf<DebugTokenSettingFeature>

    public init(store: StoreOf<DebugTokenSettingFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("디버그 디바이스 토큰 설정")
                .font(.headline)

            Text(store.guideText)
                .font(.caption)

            Button("공통값 사용") {
                store.send(.useCommonTokenButtonTapped)
            }
            .buttonStyle(.borderedProminent)

            Button("랜덤값 생성") {
                store.send(.randomButtonTapped)
            }
            .buttonStyle(.borderedProminent)

            TextField(
                "디바이스 토큰 입력",
                text: $store.tokenText
            )
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)

            Button("입력완료") {
                store.send(.confirmButtonTapped)
            }
            .buttonStyle(.bordered)
            .disabled(store.tokenText.count < 5)
        }
        .padding()
    }
}
