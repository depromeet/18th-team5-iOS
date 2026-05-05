//
//  UserPreference.swift
//  Domain
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct UserPreference: Equatable {
    public var activityStyle: ActivityStyle?
    public var activityIntensity: ActivityIntensity?
    public var themeRanking: [ActivityTheme]

    public init(
        activityStyle: ActivityStyle? = nil,
        activityIntensity: ActivityIntensity? = nil,
        themeRanking: [ActivityTheme] = []
    ) {
        self.activityStyle = activityStyle
        self.activityIntensity = activityIntensity
        self.themeRanking = themeRanking
    }
}

public enum ActivityStyle {
    case outdoor
    case indoor
}

public enum ActivityIntensity {
    case active
    case casual
}

public enum ActivityTheme: CaseIterable {
    case nature
    case food
    case culture
}
