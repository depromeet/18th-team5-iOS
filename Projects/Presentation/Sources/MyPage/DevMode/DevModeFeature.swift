//
//  DevModeFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/13/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct DevModeFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case closeButtonTapped
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .closeButtonTapped:
                return .run { _ in await dismiss() }
            }
        }
    }
}
