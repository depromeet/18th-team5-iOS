//
//  HomeView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    private let store: StoreOf<HomeFeature>

    init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    var body: some View {
        Text("홈 화면")
    }
}
