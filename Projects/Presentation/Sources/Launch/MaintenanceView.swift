//
//  MaintenanceView.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct MaintenanceView: View {
    private let store: StoreOf<MaintenanceFeature>

    public init(store: StoreOf<MaintenanceFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("서버 점검 중")
                .font(.headline)

            Text("잠시 후 다시 이용해 주세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .onAppear { store.send(.onAppear) }
    }
}
