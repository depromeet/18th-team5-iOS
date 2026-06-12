//
//  MainFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Core
import Domain
import Foundation

@Reducer
public struct MainFeature {
    public enum Alert: Equatable {
        case mission(MissionListFeature.Alert)
    }

    @ObservableState
    public struct State: Equatable {
        @Shared(.tabBarVisibility) var tabBarVisibility: Bool = true

        public var tab: Tab = .home
        var home: HomeFeature.State = .init()
        var mission: MissionListFeature.State = .init()
        var calendar: CalendarFeature.State = .init()
        var solarTermIntro: SolarTermIntroFeature.State = .init()

        var path: StackState<Path.State> = .init()
        var solarTerm: SolarTerm?
        var alert: CustomAlertFeature<Alert>.State?

        public init() {
            self._tabBarVisibility = Shared(
                wrappedValue: true,
                .tabBarVisibility
            )
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case observePushNotificationTapEvent
        case handleNotificationTapEvent
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
        case mission(MissionListFeature.Action)
        case calendar(CalendarFeature.Action)
        case solarTermIntro(SolarTermIntroFeature.Action)
        case path(StackActionOf<Path>)
        case alert(CustomAlertFeature<Alert>.Action)
        case push(Path.State)
        case popToRoot
    }

    @Dependency(\.logger) private var logger
    @Dependency(\.solarTermRepository) private var solarTermRepository
    @Dependency(\.notificationRepository) private var notificationRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Scope(state: \.mission, action: \.mission) {
            MissionListFeature()
        }

        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }

        Scope(state: \.solarTermIntro, action: \.solarTermIntro) {
            SolarTermIntroFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge([
                    .concatenate([
                        .run { send in await fetchTodaysSolarTerm(send) },
                        .send(.handleNotificationTapEvent)
                    ]),
                    .send(.observePushNotificationTapEvent)
                ])

            case .observePushNotificationTapEvent:
                let stream = NotificationCenter.default
                    .publisher(for: .pushNotificationTapped)
                    .values

                return .run { send in
                    for await _ in stream {
                        await send(.handleNotificationTapEvent)
                    }
                }

            case .handleNotificationTapEvent:
                return handleNotificationTapEvent(state)

            case let .home(.delegate(.navigateToMissionCamera(missionId, title, missionTypeRaw))):
                let missionType = MissionType(rawValue: missionTypeRaw) ?? {
                    assertionFailure("Unknown missionType: \(missionTypeRaw)")
                    return .daily
                }()

                let missionRecord = MissionRecordFeature.State(
                    missionId: missionId,
                    missionTitle: title,
                    missionType: missionType
                )

                state.path.append(.missionRecord(missionRecord))
                return .none

            case .home(.delegate(.navigateToMissionTab)):
                state.tab = .mission
                return .send(.mission(.openFromHome))

            case let .home(.delegate(.navigateToSolarTermContent(term))):
                state.path.append(.solarTermIntroContent(.init(term: term)))
                return .none

            case .home(.delegate(.navigateToMyPage)):
                guard let solarTerm = state.solarTerm else { return .none }
                state.path.append(.myPage(.init(solarTerm)))
                return .none

            case .home(.delegate(.navigateToCalendar)):
                state.tab = .calendar
                return .none

            case let .mission(.delegate(.navigateToMissionRecord(mission, missionType))):
                let missionRecord: Path.State = .missionRecord(.init(
                    missionId: mission.id,
                    missionTitle: mission.title,
                    missionType: missionType
                ))

                state.path.append(missionRecord)
                return .none

            case let .mission(.delegate(.showAlert(alert))):
                state.alert = .init(.mission(alert))
                return .none

            case .alert(.primaryButtonTapped):
                state.alert = nil
                return .none

            case .path(.element(
                id: _,
                action: .solarTermIntroContent(.delegate(.navigateToMissionTab))
            )):
                state.tab = .mission
                return .none

            case .solarTermIntro(.delegate(.navigateToMissionTab)):
                state.tab = .mission
                return .none

            case .path(.element(
                id: _,
                action: .myPage(.delegate(.syncNotificationSettings(let settings)))
            )):
                return .run { _ in
                    await syncNotificationSettings(settings)
                }

            case let .push(destination):
                state.path.append(destination)
                return .none

            case .popToRoot:
                state.path.removeAll()
                return .none

            case .alert: return .none

            case .home: return .none

            case .mission: return .none

            case .calendar: return .none

            case .solarTermIntro: return .none

            case .path: return .none

            case .binding: return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.alert, action: \.alert) {
            CustomAlertFeature()
        }
    }
}

private extension MainFeature {
    func fetchTodaysSolarTerm(_ send: Send<Action>) async {
        let year = SolarTermYear(rawValue: Date.now.year)
        guard let year else { return }
        let solarTerms = try? await solarTermRepository.fetchSolarTerms(year)
        let solarTerm = solarTerms?.first { $0.dateRange ~= Date.now }?.term
        await send(.set(\.solarTerm, solarTerm))
    }

    func syncNotificationSettings(_ settings: [NotificationType: Bool]) async {
        try? await notificationRepository.syncNotificationSettings(settings)
    }

    func handleNotificationTapEvent(_ state: State) -> Effect<Action> {
        let notificationType = notificationRepository.fetchPendingNotificationType()
        guard let notificationType else { return .none }

        return .run { [state] send in
            if let dismissCoverAction = dismissCoverAction(state) {
                await send(dismissCoverAction)
            }

            switch notificationType {
            case .dailyMission:
                await send(.set(\.tab, .home))
                await send(.popToRoot)
            case .solarTermEnd:
                await send(.set(\.tab, .calendar))
                await send(.popToRoot)
            case .solarTermStart:
                guard let solarTerm = state.solarTerm else { return }
                await send(.push(.solarTermIntroContent(.init(term: solarTerm))))
            }
        }
    }

    func dismissCoverAction(_ state: State) -> Action? {
        if state.path.last.is(\.missionRecord),
           let id = state.path.ids.last {
            return .path(.element(id: id, action: .missionRecord(.dismissAll)))
        }

        if state.tab == .mission {
            return .mission(.dismissAll)
        }

        return nil
    }
}

public extension MainFeature {
    enum Tab: CaseIterable {
        case home
        case mission
        case calendar
        case solarTerm
    }
}
