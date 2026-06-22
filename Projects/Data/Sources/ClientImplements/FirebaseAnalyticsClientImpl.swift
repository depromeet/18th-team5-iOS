//
//  FirebaseAnalyticsClientImpl.swift
//  Data
//
//  Created by 이정원 on 6/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import FirebaseAnalytics

extension AnalyticsClient: @retroactive DependencyKey {
    public static let liveValue: AnalyticsClient = FirebaseAnalyticsClientImpl.live()
}

public enum FirebaseAnalyticsClientImpl {
    private enum Event {
        static let navTabTap = "nav_tab_tap"
        static let missionScreenView = "mission_screen_view"
        static let missionCategoryTap = "mission_category_tap"
        static let missionCardNavigate = "mission_missioncard_navigate"
        static let selectMissionTap = "mission_selectmission_tap"
        static let missionCardTap = "mission_missioncard_tap"
    }

    private enum ParameterKey {
        static let tabName = "tab_name"
        static let previousTab = "previous_tab"
        static let category = "category"
        static let method = "method"
        static let direction = "direction"
        static let fromPosition = "from_position"
        static let toPosition = "to_position"
        static let missionId = "mission_id"
        static let missionName = "mission_name"
        static let cardPosition = "card_position"
        static let isCompleted = "is_completed"
    }

    private enum UserPropertyKey {
        static let userType = "user_type"
    }

    private enum DefaultParameterKey {
        static let solarTerm = "solar_term"
    }

    public static func live() -> AnalyticsClient {
        AnalyticsClient(
            setUserType: { userType in
                Analytics.setUserProperty(
                    userType.analyticsValue,
                    forName: UserPropertyKey.userType
                )
            },
            setSolarTerm: { solarTerm in
                Analytics.setDefaultEventParameters([
                    DefaultParameterKey.solarTerm: solarTerm.rawValue
                ])
            },
            logAppOpen: {
                Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
            },
            logNavTabTap: { tabName, previousTab in
                Analytics.logEvent(Event.navTabTap, parameters: [
                    ParameterKey.tabName: tabName,
                    ParameterKey.previousTab: previousTab
                ])
            },
            logMissionScreenView: {
                Analytics.logEvent(Event.missionScreenView, parameters: nil)
            },
            logMissionCategoryTap: { category in
                Analytics.logEvent(Event.missionCategoryTap, parameters: [
                    ParameterKey.category: category.analyticsValue
                ])
            },
            logSelectMissionTap: {
                Analytics.logEvent(Event.selectMissionTap, parameters: nil)
            },
            logMissionCardTap: { mission, cardPosition in
                let parameters: [String: Any?] = [
                    ParameterKey.missionId: mission.id,
                    ParameterKey.missionName: mission.title,
                    ParameterKey.category: mission.analyticsCategoryValue,
                    ParameterKey.cardPosition: cardPosition,
                    ParameterKey.isCompleted: mission.isCompleted
                ]

                Analytics.logEvent(
                    Event.missionCardTap,
                    parameters: parameters.compactMapValues { $0 }
                )
            },
            logMissionCardNavigate: { navigation in
                let parameters: [String: Any?] = [
                    ParameterKey.method: navigation.method.analyticsValue,
                    ParameterKey.direction: navigation.direction.analyticsValue,
                    ParameterKey.fromPosition: navigation.fromPosition,
                    ParameterKey.toPosition: navigation.toPosition
                ]

                Analytics.logEvent(
                    Event.missionCardNavigate,
                    parameters: parameters.compactMapValues { $0 }
                )
            }
        )
    }
}
