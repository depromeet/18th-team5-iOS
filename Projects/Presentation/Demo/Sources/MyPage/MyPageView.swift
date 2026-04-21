//
//  MyPageView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MyPageView: View {
    @Bindable private var store: StoreOf<MyPageFeature>

    init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {}
                .navigationTitle("마이페이지")
        } destination: { _ in
        }
    }
}
