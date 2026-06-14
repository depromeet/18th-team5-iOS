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
        var isLogoPresented: Bool = false
        var isLoading: Bool = false
        var alert: CustomAlertFeature<Alert>.State?
        public init() {}
    }

    public enum Action {
        case onAppear
        case splashDone
        case showAlert
        case alert(CustomAlertFeature<Alert>.Action)
        case delegate(Delegate)
    }

    public enum Alert {
        case error
    }

    public enum Delegate {
        case refresh
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLogoPresented = true
                return .run { send in
                    try await Task.sleep(for: .seconds(1.2))
                    await send(.splashDone)
                }
            case .splashDone:
                state.isLoading = true
                return .none
            case .showAlert:
                state.isLoading = false
                state.alert = .init(.error)
                return .none
            case .alert(.primaryButtonTapped):
                state = .init()
                return .send(.delegate(.refresh))
            case .alert: return .none
            case .delegate: return .none
            }
        }
        .ifLet(\.alert, action: \.alert) {
            CustomAlertFeature()
        }
    }
}
