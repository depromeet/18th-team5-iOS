//
//  OnboardingRequestDTO.swift
//  Data
//
//  Created by 이정원 on 5/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Core
import Domain

struct OnboardingRequestDTO: Encodable, Sendable {
    let spaceType: String
    let activityStyleType: String
    let enjoyTypeFirst: String
    let enjoyTypeSecond: String
    let enjoyTypeThird: String

    init(preference: UserPreference) {
        let themes = preference.themeRanking.map(\.value)
        self.spaceType = preference.activityStyle?.value ?? ""
        self.activityStyleType = preference.engagementLevel?.value ?? ""
        self.enjoyTypeFirst = themes[safe: 0] ?? ""
        self.enjoyTypeSecond = themes[safe: 1] ?? ""
        self.enjoyTypeThird = themes[safe: 2] ?? ""
    }
}

private extension ActivityStyle {
    var value: String {
        switch self {
        case .indoor: "INDOOR"
        case .outdoor: "OUTDOOR"
        }
    }
}

private extension EngagementLevel {
    var value: String {
        switch self {
        case .active: "ACTIVE"
        case .casual: "CASUAL"
        }
    }
}

private extension ActivityTheme {
    var value: String {
        switch self {
        case .nature: "NATURE_OUTDOOR"
        case .food: "SEASONAL_FOOD"
        case .culture: "CULTURE_CONTENT"
        }
    }
}
