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
    private let store: StoreOf<MyPageFeature>

    init(store: StoreOf<MyPageFeature>) {
        self.store = store
    }

    var body: some View {
        Text("마이페이지 화면")
    }
}
