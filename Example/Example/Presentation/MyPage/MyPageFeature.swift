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
    struct State {
        var path: StackState<Path.State> = .init()
    }

    enum Action {
        case path(StackActionOf<Path>)
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
        .forEach(\.path, action: \.path)
    }
}

extension MyPageFeature {
    @Reducer
    enum Path {}
}
