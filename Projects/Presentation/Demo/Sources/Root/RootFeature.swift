//
//  RootFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Presentation

@Reducer
struct RootFeature {
    @ObservableState
    struct State {
        var calendar = CalendarFeature.State()
    }

    enum Action {
        case calendar(CalendarFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }
    }
}
