//
//  AnalyticsClient.swift
//  Domain
//
//  Created by 이정원 on 6/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct AnalyticsClient: Sendable {
    public var setUserType: @Sendable (_ userType: UserType) -> Void
    public var setSolarTerm: @Sendable (_ solarTerm: SolarTerm) -> Void
    public var logAppOpen: @Sendable () -> Void
    public var logNavTabTap: @Sendable (_ tabName: String, _ previousTab: String) -> Void
    public var logOnboardingQ1Submit: @Sendable (_ answer: ActivityStyle) -> Void
    public var logOnboardingQ2Submit: @Sendable (_ answer: EngagementLevel) -> Void
    public var logOnboardingQ3Submit: @Sendable (_ ranking: [ActivityTheme]) -> Void
    public var logOnboardingCompleteSubmit: @Sendable (_ preference: UserPreference) -> Void
    public var logHomeScreenView: @Sendable () -> Void
    public var logHomeMissionShortcutTap: @Sendable () -> Void
    public var logHomeQuickRecordTap: @Sendable (_ missionId: Int) -> Void
    public var logHomeRecordMoreTap: @Sendable (_ recordCount: Int) -> Void
    public var logMissionScreenView: @Sendable () -> Void
    public var logMissionCategoryTap: @Sendable (_ category: MissionTheme) -> Void
    public var logSelectMissionTap: @Sendable () -> Void
    public var logMissionCardTap: @Sendable (_ mission: Mission, _ cardPosition: Int?) -> Void
    public var logMissionCardNavigate: @Sendable (_ navigation: MissionCardNavigation) -> Void
    public var logSeasonScreenView: @Sendable (_ season: Season) -> Void
    public var logSeasonCardTap: @Sendable (_ solarTerm: SolarTerm, _ cardPosition: Int) -> Void
}

extension AnalyticsClient: TestDependencyKey {
    public static let testValue = AnalyticsClient()
}

public extension DependencyValues {
    var analyticsClient: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}
