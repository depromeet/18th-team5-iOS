//
//  FirebaseAnalyticsClientImpl.swift
//  Data
//
//  Created by 이정원 on 6/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Core
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
        static let homeMissionShortcutTap = "home_mission_shortcut_tap"
        static let homeQuickRecordTap = "home_quick_record_tap"
        static let homeRecordMoreTap = "home_record_more_tap"
        static let missionCategoryTap = "mission_category_tap"
        static let missionCardNavigate = "mission_missioncard_navigate"
        static let selectMissionTap = "mission_selectmission_tap"
        static let missionCardTap = "mission_missioncard_tap"
        static let recordPictureTap = "record_picture_tap"
        static let recordMemoTap = "record_memo_tap"
        static let recordConfirmSubmit = "record_confirm_submit"
        static let calendarDateTap = "calendar_date_tap"
        static let calendarRecordTap = "calendar_record_tap"
        static let calendarDownloadSubmit = "calendar_download_submit"
        static let calendarShareSubmit = "calendar_share_submit"
        static let seasonFilterTap = "season_filter_tap"
        static let seasonCardTap = "season_card_tap"
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
        static let recordCount = "record_count"
        static let date = "date"
        static let hasRecord = "has_record"
        static let photoSource = "photo_source"
        static let hasPhoto = "has_photo"
        static let hasMemo = "has_memo"
        static let recordMethod = "record_method"
        static let seasonFilter = "season_filter"
        static let targetSolarTerm = "target_solar_term"
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
            logHomeScreenView: {
                Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                    AnalyticsParameterScreenName: "홈",
                    AnalyticsParameterScreenClass: "HomeView"
                ])
            },
            logHomeMissionShortcutTap: {
                Analytics.logEvent(Event.homeMissionShortcutTap, parameters: nil)
            },
            logHomeQuickRecordTap: { missionId in
                Analytics.logEvent(Event.homeQuickRecordTap, parameters: [
                    ParameterKey.missionId: missionId
                ])
            },
            logHomeRecordMoreTap: { recordCount in
                Analytics.logEvent(Event.homeRecordMoreTap, parameters: [
                    ParameterKey.recordCount: recordCount
                ])
            },
            logMissionScreenView: {
                Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                    AnalyticsParameterScreenName: "미션",
                    AnalyticsParameterScreenClass: "MissionListView"
                ])
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
            },
            logRecordScreenView: { mission in
                let parameters: [String: Any?] = [
                    AnalyticsParameterScreenName: "기록하기",
                    AnalyticsParameterScreenClass: "MissionRecordView",
                    ParameterKey.missionId: mission?.id,
                    ParameterKey.missionName: mission?.title,
                    ParameterKey.category: mission?.analyticsCategoryValue
                ]

                Analytics.logEvent(
                    AnalyticsEventScreenView,
                    parameters: parameters.compactMapValues { $0 }
                )
            },
            logRecordPictureTap: { source, missionId in
                let parameters: [String: Any?] = [
                    ParameterKey.photoSource: source.analyticsValue,
                    ParameterKey.missionId: missionId
                ]

                Analytics.logEvent(
                    Event.recordPictureTap,
                    parameters: parameters.compactMapValues { $0 }
                )
            },
            logRecordMemoTap: { missionId, hasPhoto in
                let parameters: [String: Any?] = [
                    ParameterKey.missionId: missionId,
                    ParameterKey.hasPhoto: hasPhoto
                ]

                Analytics.logEvent(
                    Event.recordMemoTap,
                    parameters: parameters.compactMapValues { $0 }
                )
            },
            logRecordConfirmSubmit: { mission, hasPhoto, hasMemo in
                let recordMethod = RecordMethod(hasPhoto: hasPhoto, hasMemo: hasMemo)

                let parameters: [String: Any?] = [
                    ParameterKey.missionId: mission?.id,
                    ParameterKey.missionName: mission?.title,
                    ParameterKey.category: mission?.analyticsCategoryValue,
                    ParameterKey.hasPhoto: hasPhoto,
                    ParameterKey.hasMemo: hasMemo,
                    ParameterKey.recordMethod: recordMethod.analyticsValue
                ]

                Analytics.logEvent(
                    Event.recordConfirmSubmit,
                    parameters: parameters.compactMapValues { $0 }
                )
            },
            logCalendarScreenView: {
                Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                    AnalyticsParameterScreenName: "캘린더",
                    AnalyticsParameterScreenClass: "CalendarView"
                ])
            },
            logCalendarDateTap: { date, hasRecord in
                Analytics.logEvent(Event.calendarDateTap, parameters: [
                    ParameterKey.date: date.string(.yearMonthDayDash),
                    ParameterKey.hasRecord: hasRecord
                ])
            },
            logCalendarRecordTap: {
                Analytics.logEvent(Event.calendarRecordTap, parameters: nil)
            },
            logCalendarDownloadSubmit: { missionName in
                let parameters: [String: Any?] = [
                    ParameterKey.missionName: missionName
                ]

                Analytics.logEvent(
                    Event.calendarDownloadSubmit,
                    parameters: parameters.compactMapValues { $0 }
                )
            },
            logCalendarShareSubmit: { missionName in
                let parameters: [String: Any?] = [
                    ParameterKey.missionName: missionName
                ]

                Analytics.logEvent(
                    Event.calendarShareSubmit,
                    parameters: parameters.compactMapValues { $0 }
                )
            },
            logSeasonScreenView: { season in
                Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                    AnalyticsParameterScreenName: "절기소개",
                    AnalyticsParameterScreenClass: "SolarTermIntroView",
                    ParameterKey.seasonFilter: season.displayName
                ])
            },
            logSeasonFilterTap: { season in
                Analytics.logEvent(Event.seasonFilterTap, parameters: [
                    ParameterKey.seasonFilter: season.displayName
                ])
            },
            logSeasonCardTap: { solarTerm, cardPosition in
                Analytics.logEvent(Event.seasonCardTap, parameters: [
                    ParameterKey.targetSolarTerm: solarTerm.koreanName,
                    ParameterKey.cardPosition: cardPosition
                ])
            }
        )
    }
}
