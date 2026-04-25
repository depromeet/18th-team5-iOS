//
//  ForceUpdateView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct ForceUpdateFeature {
    @ObservableState
    public struct State {
        public init() {}
    }

    public enum Action {
        case updateButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}

public struct ForceUpdateView: View {
    private let store: StoreOf<ForceUpdateFeature>

    public init(store: StoreOf<ForceUpdateFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("업데이트가 필요합니다")
                .font(.headline)

            Button("App Store로 이동") {
                store.send(.updateButtonTapped)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
