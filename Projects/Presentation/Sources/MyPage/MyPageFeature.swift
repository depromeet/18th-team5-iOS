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
        var privacyPolicies: [DocumentInfo]?
        var termsOfService: [DocumentInfo]?
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
        case fetchAll
        case backButtonTapped
        case menuTapped(Menu)
        case updateButtonTapped
        case deleteButtonTapped
        case privacyPolicyFetched([DocumentInfo])
        case termsOfServiceFetched([DocumentInfo])
        case path(PresentationAction<Path.Action>)
        case delegate(Delegate)
    }

    public enum Delegate {
        case syncNotificationSettings([NotificationType: Bool])
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchAll)
            case .fetchAll:
                return .run { [state] send in
                    await fetchAll(state, send)
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
                    guard state.privacyPolicies?.isEmpty == true else { return .none }
                    return .run { [state] send in
                        await fetchPrivacyPolicy(state, send)
                    }
                case .termsOfService:
                    state.path = .termsOfService(.init(state.termsOfService))
                    guard state.termsOfService?.isEmpty == true else { return .none }
                    return .run { [state] send in
                        await fetchTermsOfService(state, send)
                    }
                default: return .none
                }
            case let .path(.presented(.notificationSettings(action))):
                switch action {
                case let .delegate(.syncNotificationSettings(settings)):
                    return .send(.delegate(.syncNotificationSettings(settings)))
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
            case let .termsOfServiceFetched(terms):
                state.termsOfService = terms
                guard case .termsOfService = state.path else { return .none }
                return .send(.path(.presented(
                    .termsOfService(.termsOfServiceFetched(terms))
                )))
            case .path: return .none
            case .delegate: return .none
            }
        }
        .ifLet(\.$path, action: \.path)
    }
}

private extension MyPageFeature {
    func fetchAll(_ state: State, _ send: Send<Action>) async {
        async let privacyPolicy = fetchPrivacyPolicy(state, send)
        async let fetchTermsOfService = fetchTermsOfService(state, send)
        _ = await (privacyPolicy, fetchTermsOfService)
    }

    func fetchPrivacyPolicy(_ state: State, _ send: Send<Action>) async {
        if state.privacyPolicies?.isEmpty == false { return }
        let policies = try? await myPageRepository.fetchPrivacyPolicy()
        await send(.privacyPolicyFetched(policies ?? []))
    }

    func fetchTermsOfService(_ state: State, _ send: Send<Action>) async {
        if state.termsOfService?.isEmpty == false { return }
        let terms = try? await myPageRepository.fetchTermsOfService()
        await send(.termsOfServiceFetched(terms ?? []))
    }
}
