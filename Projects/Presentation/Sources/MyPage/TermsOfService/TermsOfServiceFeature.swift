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

        public init(_ termsOfService: [DocumentInfo]?) {
            self.termsOfService = termsOfService
            self.isLoading = termsOfService == nil
        }
    }

    public enum Action {
        case onAppear
        case backButtonTapped
        case termsOfServiceFetched([DocumentInfo])
        case showAlert
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.termsOfService?.isEmpty == true {
                    return .send(.showAlert)
                }
                return .none
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
                // TODO: Alert처리 - @정원
                return .none
            }
        }
    }
}
