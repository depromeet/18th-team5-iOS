//
//  UserPreference.swift
//  Domain
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct UserPreference: Equatable {
    public var activityStyle: ActivityStyle?
    public var engagementLevel: EngagementLevel?
    public var themeRanking: [ActivityTheme]

    public init(
        activityStyle: ActivityStyle? = nil,
        engagementLevel: EngagementLevel? = nil,
        themeRanking: [ActivityTheme] = []
    ) {
        self.activityStyle = activityStyle
        self.engagementLevel = engagementLevel
        self.themeRanking = themeRanking
    }

    public var userType: UserType? {
        switch (activityStyle, engagementLevel) {
        case (.outdoor, .active): .natureExplorer
        case (.outdoor, .casual): .localWanderer
        case (.indoor, .active): .seasonalGourmet
        case (.indoor, .casual): .dailyObserver
        default: nil
        }
    }
}

public enum ActivityStyle {
    case outdoor
    case indoor
}

public enum EngagementLevel {
    case active
    case casual
}

public enum ActivityTheme {
    case nature
    case food
    case culture
}
