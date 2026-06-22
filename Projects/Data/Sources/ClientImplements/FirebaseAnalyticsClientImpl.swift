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
        static let onboardingQ1Submit = "onboarding_q1_submit"
        static let onboardingQ2Submit = "onboarding_q2_submit"
        static let onboardingQ3Submit = "onboarding_q3_submit"
        static let onboardingCompleteSubmit = "onboarding_complete_submit"
        static let missionScreenView = "mission_screen_view"
        static let missionCategoryTap = "mission_category_tap"
        static let missionCardNavigate = "mission_missioncard_navigate"
        static let selectMissionTap = "mission_selectmission_tap"
        static let missionCardTap = "mission_missioncard_tap"
    }

    private enum ParameterKey {
        static let tabName = "tab_name"
        static let previousTab = "previous_tab"
        static let q1Answer = "q1_answer"
        static let q2Answer = "q2_answer"
        static let q3Rank1 = "q3_rank1"
        static let q3Rank2 = "q3_rank2"
        static let q3Rank3 = "q3_rank3"
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
        static let placePreference = "user_place_pref"
        static let activityStyle = "user_activity_style"
        static let contentRank1 = "user_content_rank1"
        static let contentRank2 = "user_content_rank2"
        static let contentRank3 = "user_content_rank3"
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
            logOnboardingQ1Submit: { answer in
                Analytics.logEvent(Event.onboardingQ1Submit, parameters: [
                    ParameterKey.q1Answer: answer.analyticsValue
                ])
            },
            logOnboardingQ2Submit: { answer in
                Analytics.logEvent(Event.onboardingQ2Submit, parameters: [
                    ParameterKey.q2Answer: answer.analyticsValue
                ])
            },
            logOnboardingQ3Submit: { ranking in
                guard ranking.count == 3 else { return }
                let values = ranking.map(\.analyticsValue)

                Analytics.logEvent(Event.onboardingQ3Submit, parameters: [
                    ParameterKey.q3Rank1: values[0],
                    ParameterKey.q3Rank2: values[1],
                    ParameterKey.q3Rank3: values[2]
                ])
            },
            logOnboardingCompleteSubmit: { preference in
                guard let activityStyle = preference.activityStyle,
                      let engagementLevel = preference.engagementLevel,
                      preference.themeRanking.count == 3 else { return }

                let ranking = preference.themeRanking.map(\.analyticsValue)
                Analytics.setUserProperty(
                    activityStyle.analyticsValue,
                    forName: UserPropertyKey.placePreference
                )

                Analytics.setUserProperty(
                    engagementLevel.analyticsValue,
                    forName: UserPropertyKey.activityStyle
                )

                Analytics.setUserProperty(ranking[0], forName: UserPropertyKey.contentRank1)
                Analytics.setUserProperty(ranking[1], forName: UserPropertyKey.contentRank2)
                Analytics.setUserProperty(ranking[2], forName: UserPropertyKey.contentRank3)
                Analytics.logEvent(Event.onboardingCompleteSubmit, parameters: [
                    ParameterKey.q1Answer: activityStyle.analyticsValue,
                    ParameterKey.q2Answer: engagementLevel.analyticsValue,
                    ParameterKey.q3Rank1: ranking[0]
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
