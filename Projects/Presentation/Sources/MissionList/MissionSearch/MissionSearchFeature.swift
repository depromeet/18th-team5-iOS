//
//  MissionSearchFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/24/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct MissionSearchFeature {
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
