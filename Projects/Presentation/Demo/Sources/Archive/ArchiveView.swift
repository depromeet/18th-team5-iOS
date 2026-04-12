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
    private let store: StoreOf<ArchiveFeature>

    init(store: StoreOf<ArchiveFeature>) {
        self.store = store
    }

    var body: some View {
        Text("아카이빙 화면")
    }
}
