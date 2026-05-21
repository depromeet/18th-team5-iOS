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
        var category: Category = .all
        var isTooltipPresented: Bool = true

        public init() {}

        var isSelectMissionButtonEnabled: Bool {
            // TODO: 추후 로직 구현
            true
        }
    }

    public enum Action: BindableAction {
        case selectMissionButtonTapped
        case binding(BindingAction<State>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .selectMissionButtonTapped:
                state.isTooltipPresented = true
                return .none
            case .binding: return .none
            }
        }
    }
}

extension MissionListFeature {
    enum Category: CaseIterable {
        case all
        case food
        case contents
        case activity
    }
}
