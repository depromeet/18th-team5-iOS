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
        var privacyPolicies: [PrivacyPolicyInfo]?
        var isLoading: Bool

        public init(_ privacyPolicies: [PrivacyPolicyInfo]?) {
            self.privacyPolicies = privacyPolicies
            self.isLoading = privacyPolicies == nil
        }
    }

    public enum Action {
        case onAppear
        case backButtonTapped
        case privacyPolicyFetched([PrivacyPolicyInfo])
        case showAlert
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.privacyPolicies?.isEmpty == true {
                    return .send(.showAlert)
                }
                return .none
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
                // TODO: Alert처리 - @정원
                return .none
            }
        }
    }
}
