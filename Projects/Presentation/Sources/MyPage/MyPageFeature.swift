//
//  MyPageFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct MyPageFeature {
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.myPageRepository) private var myPageRepository

    public enum Menu {
        case notificationSettings
        case announcements
        case contactUs
        case termsOfService
        case privacyPolicy
    }

    @ObservableState
    public struct State: Equatable {
        let solarTerm: SolarTerm
        var privacyPolicies: [PrivacyPolicyInfo]?
        var version: String = "1.3.2" // TODO: 추후 수정 예정 - @정원
        @Presents var path: Path.State?

        public init(_ solarTerm: SolarTerm) {
            self.solarTerm = solarTerm
        }

        var season: Season {
            solarTerm.season
        }
    }

    public enum Action {
        case onAppear
        case fetchPrivacyPolicy
        case backButtonTapped
        case menuTapped(Menu)
        case updateButtonTapped
        case deleteButtonTapped
        case privacyPolicyFetched([PrivacyPolicyInfo])
        case path(PresentationAction<Path.Action>)
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchPrivacyPolicy)
            case .fetchPrivacyPolicy:
                return .run { [state] send in
                    await fetchPrivacyPolicy(state, send)
                }
            case .backButtonTapped:
                return .run { _ in await dismiss() }
            case let .menuTapped(menu):
                switch menu {
                case .notificationSettings:
                    state.path = .notificationSettings(.init(state.season))
                    return .none
                case .privacyPolicy:
                    state.path = .privacyPolicy(.init(state.privacyPolicies))
                    if state.privacyPolicies?.isEmpty == true {
                        return .send(.fetchPrivacyPolicy)
                    }
                    return .none
                default: return .none
                }
            case .updateButtonTapped:
                return .none
            case .deleteButtonTapped:
                return .none
            case let .privacyPolicyFetched(policies):
                state.privacyPolicies = policies
                guard case .privacyPolicy = state.path else { return .none }
                return .send(.path(.presented(
                    .privacyPolicy(.privacyPolicyFetched(policies))
                )))
            case .path: return .none
            }
        }
        .ifLet(\.$path, action: \.path)
    }
}

private extension MyPageFeature {
    func fetchPrivacyPolicy(_ state: State, _ send: Send<Action>) async {
        if state.privacyPolicies?.isEmpty == false { return }
        let policies = try? await myPageRepository.fetchPrivacyPolicy()
        await send(.privacyPolicyFetched(policies ?? []))
    }
}
