//
//  ArchiveView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ArchiveView: View {
    @Bindable private var store: StoreOf<ArchiveFeature>

    init(store: StoreOf<ArchiveFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {}
                .navigationTitle("아카이빙")
        } destination: { _ in
        }
    }
}
