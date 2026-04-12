//
//  MyPageFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct MyPageFeature {
    @ObservableState
    struct State {}

    enum Action {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}
