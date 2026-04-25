//
//  SplashFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct SplashFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case onAppear
        case splashDone
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear, .splashDone:
                return .none
            }
        }
    }
}
