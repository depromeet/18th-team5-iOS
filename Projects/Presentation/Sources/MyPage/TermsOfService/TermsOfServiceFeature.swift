//
//  TermsOfServiceFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct TermsOfServiceFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        var termsOfService: [DocumentInfo]?
        var isLoading: Bool
        var alert: CustomAlertFeature<Alert>.State?

        public init(_ termsOfService: [DocumentInfo]?) {
            self.termsOfService = termsOfService
            self.isLoading = termsOfService?.isEmpty != false
        }
    }

    public enum Action {
        case backButtonTapped
        case termsOfServiceFetched([DocumentInfo])
        case showAlert
        case alert(CustomAlertFeature<Alert>.Action)
        case delegate(Delegate)
    }

    public enum Alert {
        case fetchFailed
    }

    public enum Delegate {
        case refresh
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case let .termsOfServiceFetched(terms):
                if terms.isEmpty {
                    state.isLoading = false
                    return .send(.showAlert)
                } else {
                    state.termsOfService = terms
                    state.isLoading = false
                    return .none
                }
            case .showAlert:
                state.isLoading = false
                state.alert = .init(.fetchFailed)
                return .none
            case .alert(.primaryButtonTapped):
                state.alert = nil
                state.isLoading = true
                return .send(.delegate(.refresh))
            case .alert(.secondaryButtonTapped):
                return .send(.backButtonTapped)
            case .delegate: return .none
            }
        }
        .ifLet(\.alert, action: \.alert) {
            CustomAlertFeature()
        }
    }
}
