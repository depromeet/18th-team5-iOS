//
//  DevModeView.swift
//  Presentation
//
//  Created by 이정원 on 6/13/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct DevModeView: View {
    private let store: StoreOf<DevModeFeature>

    public init(store: StoreOf<DevModeFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {}
            .navigationBar(
                title: "개발자 모드",
                dismissType: .close,
                action: { store.send(.closeButtonTapped) }
            )
    }
}
