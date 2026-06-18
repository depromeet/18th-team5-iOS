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
    public var logMissionScreenView: @Sendable () -> Void
    public var logMissionCategoryTap: @Sendable (_ category: MissionTheme) -> Void
    public var logSelectMissionTap: @Sendable () -> Void
    public var logMissionCardTap: @Sendable (_ mission: Mission, _ cardPosition: Int?) -> Void
    public var logMissionCardNavigate: @Sendable (_ navigation: MissionCardNavigation) -> Void
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
