//
//  UserType.swift
//  Domain
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public enum UserType {
    case natureExplorer
    case localWanderer
    case seasonalGourmet
    case dailyObserver

    public init?(
        activityStyle: ActivityStyle?,
        engagementLevel: EngagementLevel?
    ) {
        guard let activityStyle, let engagementLevel else {
            return nil
        }

        self = switch (activityStyle, engagementLevel) {
        case (.outdoor, .active): .natureExplorer
        case (.outdoor, .casual): .localWanderer
        case (.indoor, .active): .seasonalGourmet
        case (.indoor, .casual): .dailyObserver
        }
    }

    public var name: String {
        switch self {
        case .natureExplorer: "자연 탐험가"
        case .localWanderer: "동네 산책러"
        case .seasonalGourmet: "제철 미식가"
        case .dailyObserver: "일상 관찰자"
        }
    }
}
