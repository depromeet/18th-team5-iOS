//
//  ForceUpdateFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct ForceUpdateFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case updateButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}
