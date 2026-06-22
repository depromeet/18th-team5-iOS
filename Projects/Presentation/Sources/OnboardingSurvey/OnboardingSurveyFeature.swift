//
//  OnboardingSurveyFeature.swift
//  Presentation
//
//  Created by 이정원 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain

@Reducer
public struct OnboardingSurveyFeature {
    @Dependency(\.onboardingRepository) private var onboardingRepository
    @Dependency(\.analyticsClient) private var analyticsClient

    enum Status: Equatable {
        case initial
        case inProgress
        case result
    }

    @ObservableState
    public struct State: Equatable {
        var status: Status = .initial
        let stepCount: Int = 3
        var step: Int = 0
        var preference: UserPreference = .init()
        var isLoading: Bool = false

        public init() {}

        var userType: UserType? {
            UserType(
                activityStyle: preference.activityStyle,
                engagementLevel: preference.engagementLevel
            )
        }
    }

    public enum Action: BindableAction {
        case backButtonTapped
        case bottomButtonTapped
        case binding(BindingAction<State>)
        case delegate(Delegate)
    }

    public enum Delegate {
        case completed
    }

    public init() {}
    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                switch state.step {
                case 0: state.status = .initial
                default: state.step -= 1
                }
                return .none
            case .bottomButtonTapped:
                switch state.status {
                case .initial:
                    state.status = .inProgress
                    return .none
                case .inProgress:
                    logOnboardingSubmit(state)
                    switch state.step {
                    case 0 ..< 2: state.step += 1
                    case 2: state.status = .result
                    default: break
                    }
                    return .none
                case .result:
                    state.isLoading = true
                    return .run { [state] send in
                        await submitOnboardingInfo(state, send)
                    }
                }
            case .binding: return .none
            case .delegate: return .none
            }
        }
    }
}

private extension OnboardingSurveyFeature {
    func submitOnboardingInfo(_ state: State, _ send: Send<Action>) async {
        do {
            try await onboardingRepository.submitOnboardingInfo(state.preference)

            if let userType = state.userType {
                analyticsClient.setUserType(userType)
                analyticsClient.logOnboardingCompleteSubmit(state.preference)
            }

            await send(.set(\.isLoading, false))
            await send(.delegate(.completed))
        } catch {
            await send(.set(\.isLoading, false))
        }
    }

    func logOnboardingSubmit(_ state: State) {
        switch state.step {
        case 0:
            guard let answer = state.preference.activityStyle else { return }
            analyticsClient.logOnboardingQ1Submit(answer)
        case 1:
            guard let answer = state.preference.engagementLevel else { return }
            analyticsClient.logOnboardingQ2Submit(answer)
        case 2:
            analyticsClient.logOnboardingQ3Submit(state.preference.themeRanking)
        default: break
        }
    }
}
