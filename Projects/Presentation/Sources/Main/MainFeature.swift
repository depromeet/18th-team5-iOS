//
//  MainFeature.swift
//  Presentation
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct MainFeature {
    @Dependency(\.notificationRepository) private var notificationRepository

    @ObservableState
    public struct State: Equatable {
        @Shared(.tabBarVisibility) var tabBarVisibility: Bool = true

        public var tab: Tab = .home
        var home: HomeFeature.State = .init()
        var solarTermIntro: SolarTermIntroFeature.State = .init()
        var mission: MissionListFeature.State = .init()
        var calendar: CalendarFeature.State = .init()

        @Presents var missionRecord: MissionRecordFeature.State?
        @Presents var solarTermIntroContent: SolarTermIntroContentFeature.State?

        init() {
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
        case missionRecord(PresentationAction<MissionRecordFeature.Action>)
        case solarTermIntro(SolarTermIntroFeature.Action)
        case solarTermIntroContent(PresentationAction<SolarTermIntroContentFeature.Action>)
        case presentSolarTermContent(SolarTermIntro, String)
    }

    @Dependency(\.logger) var logger
    @Dependency(\.solarTermIntroRepository) var solarTermIntroRepository
    @Dependency(\.solarTermRepository) var solarTermRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.calendar, action: \.calendar) {
            CalendarFeature()
        }

        Scope(state: \.solarTermIntro, action: \.solarTermIntro) {
            SolarTermIntroFeature()
        }
        Scope(state: \.mission, action: \.mission) {
            MissionListFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await checkNotificationSettings(send)
                }

            case let .home(.delegate(.navigateToMissionCamera(missionId, title, missionTypeRaw, solarTermId))):
                let missionType = MissionType(rawValue: missionTypeRaw) ?? {
                    assertionFailure("Unknown missionType: \(missionTypeRaw)")
                    return .daily
                }()
                state.missionRecord = MissionRecordFeature.State(
                    missionId: missionId,
                    missionTitle: title,
                    missionType: missionType,
                    solarTermId: solarTermId
                )
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

            case let .presentSolarTermContent(intro, dateLabel):
                state.solarTermIntroContent = SolarTermIntroContentFeature.State(
                    solarTermIntro: intro,
                    season: intro.term.season,
                    dateLabel: dateLabel
                )
                return .none

            case .solarTermIntroContent(.presented(.delegate(.dismiss))):
                state.solarTermIntroContent = nil
                return .none

            case .solarTermIntroContent(.presented(.delegate(.navigateToMissionTab))):
                state.solarTermIntroContent = nil
                state.tab = .mission
                return .none

            case .solarTermIntroContent:
                return .none

            case .missionRecord(.presented(.delegate(.dismiss))):
                state.missionRecord = nil
                return .none

            case .missionRecord(.presented(.delegate(.submitted))):
                state.missionRecord = nil
                return .none

            case .missionRecord:
                return .none

            case .home:
                return .none

            case .mission:
                return .none

            case .calendar:
                return .none

            case .solarTermIntro(.delegate(.navigateToMissionTab)):
                state.tab = .mission
                return .none

            case .solarTermIntro:
                return .none

            case .binding:
                return .none
            }
        }
        .ifLet(\.$missionRecord, action: \.missionRecord) {
            MissionRecordFeature()
        }
        .ifLet(\.$solarTermIntroContent, action: \.solarTermIntroContent) {
            SolarTermIntroContentFeature()
        }
    }
}

private extension MainFeature {
    func checkNotificationSettings(_ send: Send<Action>) async {
        do {
            let settings = try await notificationRepository.fetchNotificationSettings()
            guard let settings else { return }
            try await notificationRepository.syncNotificationSettings(settings)
        } catch {
            // TODO: 에러 처리 - 정원
        }
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
