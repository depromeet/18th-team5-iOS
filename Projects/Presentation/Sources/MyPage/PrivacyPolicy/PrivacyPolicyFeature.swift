//
//  PrivacyPolicyFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct PrivacyPolicyFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        var privacyPolicies: [DocumentInfo]?
        var isLoading: Bool
        var alert: CustomAlertFeature<Alert>.State?

        public init(_ privacyPolicies: [DocumentInfo]?) {
            self.privacyPolicies = privacyPolicies
            self.isLoading = privacyPolicies?.isEmpty != false
        }
    }

    public enum Action {
        case backButtonTapped
        case privacyPolicyFetched([DocumentInfo])
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
            case let .privacyPolicyFetched(policies):
                if policies.isEmpty {
                    state.isLoading = false
                    return .send(.showAlert)
                } else {
                    state.privacyPolicies = policies
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
            case .alert: return .none
            case .delegate: return .none
            }
        }
        .ifLet(\.alert, action: \.alert) {
            CustomAlertFeature()
        }
    }
}
