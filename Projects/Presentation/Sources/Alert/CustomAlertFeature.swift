//
//  CustomAlertFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
public struct CustomAlertFeature<Alert: AlertPresentable> {
    @ObservableState
    public struct State: Equatable {
        var alert: Alert

        public init(_ alert: Alert) {
            self.alert = alert
        }
    }

    public enum Action {
        case primaryButtonTapped(Alert)
        case secondaryButtonTapped(Alert)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
