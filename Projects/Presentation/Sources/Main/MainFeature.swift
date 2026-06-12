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
        case binding(BindingAction<State>)
        case home(HomeFeature.Action)
        case mission(MissionListFeature.Action)
        case calendar(CalendarFeature.Action)
        case solarTermIntro(SolarTermIntroFeature.Action)
        case presentSolarTermContent(SolarTermIntro, String)
        case path(StackActionOf<Path>)
        case alert(CustomAlertFeature<Alert>.Action)
    }

    @Dependency(\.logger) private var logger
    @Dependency(\.solarTermIntroRepository) private var solarTermIntroRepository
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
                return .run { send in
                    await fetchTodaysSolarTerm(send)
                }

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
                return .none

            case let .home(.delegate(.navigateToSolarTermContent(term))):
                return .run { send in
                    do {
                        let cards = try await solarTermIntroRepository.fetchSolarTermCard()
                        let infos = try await solarTermRepository.fetchSolarTerms(.current)
                        let card = cards.first { $0.term == term }
                        let dateLabel = infos.first { $0.term == term }?.formattedFullDateRange
                        if let card {
                            await send(.presentSolarTermContent(card, dateLabel ?? ""))
                        }
                    } catch {
                        // TODO: Firebase 전환 후 에러핸들링 추가 - @minkyo
                    }
                }

            case .home(.delegate(.navigateToMyPage)):
                guard let solarTerm = state.solarTerm else { return .none }
                state.path.append(.myPage(.init(solarTerm)))
                return .none

            case let .presentSolarTermContent(intro, dateLabel):
                let solarTermIntroContent = SolarTermIntroContentFeature.State(
                    solarTermIntro: intro,
                    season: intro.term.season,
                    dateLabel: dateLabel
                )
                state.path.append(.solarTermIntroContent(solarTermIntroContent))
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

            case .calendar(.delegate(.navigateToFreeRecord)):
                state.path.append(.freeRecord(.init(recordDate: Date.now)))
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
}

public extension MainFeature {
    enum Tab: CaseIterable {
        case home
        case mission
        case calendar
        case solarTerm
    }
}
