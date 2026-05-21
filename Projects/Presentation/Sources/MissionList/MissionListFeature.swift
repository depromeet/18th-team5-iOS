//
//  MissionListFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MissionListFeature {
    @ObservableState
    public struct State: Equatable {
        var nickname: String = "제철을 쫓는 탐험가"
        var solarTerm: SolarTerm = .ibha
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
