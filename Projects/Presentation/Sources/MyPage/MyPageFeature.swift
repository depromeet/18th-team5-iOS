//
//  MyPageFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct MyPageFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {}

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}
