//
//  NotificationView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

struct NotificationView: View {
    private let store: StoreOf<NotificationFeature>

    init(store: StoreOf<NotificationFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {}
            .navigationTitle("알림")
            .toolbar(.hidden, for: .tabBar)
    }
}
