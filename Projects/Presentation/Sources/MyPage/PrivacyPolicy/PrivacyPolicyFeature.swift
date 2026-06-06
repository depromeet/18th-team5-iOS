//
//  PrivacyPolicyFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct PrivacyPolicyFeature {
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
