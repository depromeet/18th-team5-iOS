//
//  SignInView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SignInView: View {
    private let store: StoreOf<SignInFeature>

    init(store: StoreOf<SignInFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("로그인 화면")

            Button("로그인") {
                store.send(.signInButtonTapped)
            }
        }
    }
}
