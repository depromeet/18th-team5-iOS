//
//  MyPageFeature.swift
//  Presentation
//
//  Created by 이정원 on 6/2/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Core
import Domain
import Foundation

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
        var contactUsURL: URL?
        let currentVersion: AppVersion = .current
        var latestVersion: AppVersion?

        @Presents var path: Path.State?

        public init(_ solarTerm: SolarTerm) {
            self.solarTerm = solarTerm
        }

        var season: Season {
            solarTerm.season
        }

        var canUpdate: Bool {
            guard let latestVersion else { return false }
            return currentVersion < latestVersion
        }

        var storeURL: URL? {
            guard let latestVersion else { return nil }

            let urlString = switch latestVersion.major {
            case 1...: Constant.appStoreURL
            default: Constant.testFlightURL
            }

            return URL(string: urlString)
        }
    }

    public enum Action {
        case onAppear
        case fetchAll
        case backButtonTapped
        case menuTapped(Menu)
        case deleteButtonTapped
        case contactUsURLFetched(URL?)
        case privacyPolicyFetched([DocumentInfo])
        case termsOfServiceFetched([DocumentInfo])
        case latestAppVersionFetched(AppVersion?)
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
                case .announcements:
                    state.path = .announcements(.init())
                    return .none
                case .termsOfService:
                    state.path = .termsOfService(.init(state.termsOfService))
                    guard state.termsOfService?.isEmpty == true else { return .none }
                    return .run { [state] send in
                        await fetchTermsOfService(state, send)
                    }
                case .privacyPolicy:
                    state.path = .privacyPolicy(.init(state.privacyPolicies))
                    guard state.privacyPolicies?.isEmpty == true else { return .none }
                    return .run { [state] send in
                        await fetchPrivacyPolicy(state, send)
                    }
                default: return .none
                }
            case let .path(.presented(.notificationSettings(action))):
                switch action {
                case let .delegate(.syncNotificationSettings(settings)):
                    return .send(.delegate(.syncNotificationSettings(settings)))
                default: return .none
                }
            case .deleteButtonTapped:
                return .none
            case let .contactUsURLFetched(url):
                state.contactUsURL = url
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
            case let .latestAppVersionFetched(latestVersion):
                state.latestVersion = latestVersion
                return .none
            case .path: return .none
            case .delegate: return .none
            }
        }
        .ifLet(\.$path, action: \.path)
    }
}

private extension MyPageFeature {
    func fetchAll(_ state: State, _ send: Send<Action>) async {
        await withTaskGroup { group in
            group.addTask { await fetchPrivacyPolicy(state, send) }
            group.addTask { await fetchTermsOfService(state, send) }
            group.addTask { await fetchContactUsURL(state, send) }
            group.addTask { await fetchLatestAppVersion(send) }
        }
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

    func fetchContactUsURL(_ state: State, _ send: Send<Action>) async {
        guard state.contactUsURL == nil else { return }
        let urlString = try? await myPageRepository.fetchContactUsURL()

        if let urlString {
            await send(.contactUsURLFetched(URL(string: urlString)))
        }
    }

    func fetchLatestAppVersion(_ send: Send<Action>) async {
        let latestVersion = try? await myPageRepository.fetchLatestAppVersion()
        await send(.latestAppVersionFetched(latestVersion))
    }
}
