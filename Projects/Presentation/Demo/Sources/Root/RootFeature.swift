//
//  RootFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State {}

    enum Action {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}
