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
    @Dependency(\.notificationRepository) private var notificationRepository
    @Dependency(\.authRepository) private var authRepository

    public enum Menu {
        case notificationSettings
        case announcements
        case contactUs
        case termsOfService
        case privacyPolicy
    }

    public enum Alert {
        case delete
        case deleteFailed
    }

    private enum CancelID { case resetData }

    @ObservableState
    public struct State: Equatable {
        let solarTerm: SolarTerm
        var privacyPolicies: [DocumentInfo]?
        var termsOfService: [DocumentInfo]?
        var contactUsURL: URL?
        let currentVersion: AppVersion = .current
        var latestVersion: AppVersion?

        var isDevModeEnabled: Bool
        var userID: Int?

        @Presents var path: Path.State?
        @Presents var devMode: DevModeFeature.State?
        var alert: CustomAlertFeature<Alert>.State?
        var isLoading: Bool = false

        public init(_ solarTerm: SolarTerm, _ config: MyPageConfig?) {
            self.solarTerm = solarTerm
            self.contactUsURL = config?.contactUsURL
            self.latestVersion = config?.latestAppVersion
            self.isDevModeEnabled = config?.isDevModeEnabled ?? false
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
        case privacyPolicyFetched([DocumentInfo])
        case termsOfServiceFetched([DocumentInfo])
        case userIDFetched(Int?)
        case userDataResetCompleted
        case path(PresentationAction<Path.Action>)
        case devMode(PresentationAction<DevModeFeature.Action>)
        case deviceShaked
        case deleteTimeout
        case delegate(Delegate)
        case showAlert(Alert)
        case alert(CustomAlertFeature<Alert>.Action)
    }

    public enum Delegate {
        case syncNotificationSettings([NotificationType: Bool])
        case navigateToSplash
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
                state.alert = .init(.delete)
                return .none
            case .deleteTimeout:
                state.isLoading = false
                state.alert = .init(.deleteFailed)
                return .cancel(id: CancelID.resetData)
            case let .showAlert(alert):
                state.isLoading = false
                state.alert = .init(alert)
                return .none
            case let .alert(.primaryButtonTapped(alert)):
                state.alert = nil

                switch alert {
                case .delete:
                    state.isLoading = true
                    return .merge([
                        .run { send in
                            try await Task.sleep(for: .seconds(10))
                            await send(.deleteTimeout)
                        },
                        .run { send in
                            await resetUserData(send)
                        }
                        .cancellable(id: CancelID.resetData)
                    ])
                case .deleteFailed:
                    return .none
                }
            case .alert(.secondaryButtonTapped):
                state.alert = nil
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
            case let .userIDFetched(userID):
                state.userID = userID
                return .none
            case .userDataResetCompleted:
                return .send(.delegate(.navigateToSplash))
            case .deviceShaked:
                guard state.isDevModeEnabled else { return .none }
                state.devMode = .init(state.userID)
                return .none
            case .devMode: return .none
            case .path: return .none
            case .delegate: return .none
            }
        }
        .ifLet(\.$path, action: \.path)
        .ifLet(\.$devMode, action: \.devMode) {
            DevModeFeature()
        }
        .ifLet(\.alert, action: \.alert) {
            CustomAlertFeature()
        }
    }
}

private extension MyPageFeature {
    func fetchAll(_ state: State, _ send: Send<Action>) async {
        await withTaskGroup { group in
            group.addTask { await fetchPrivacyPolicy(state, send) }
            group.addTask { await fetchTermsOfService(state, send) }
            group.addTask { await fetchUserInfo(send) }
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

    func fetchUserInfo(_ send: Send<Action>) async {
        let userID = try? await myPageRepository.fetchUserID()
        await send(.userIDFetched(userID))
    }

    func resetUserData(_ send: Send<Action>) async {
        do {
            let settings: [NotificationType: Bool] = [
                .dailyMission: false,
                .solarTermStart: false,
                .solarTermEnd: false
            ]

            try await notificationRepository.syncNotificationSettings(settings)
            try await myPageRepository.resetUserData()
            try await authRepository.signOut()
            await send(.userDataResetCompleted)
        } catch {
            await send(.showAlert(.deleteFailed))
        }
    }
}
