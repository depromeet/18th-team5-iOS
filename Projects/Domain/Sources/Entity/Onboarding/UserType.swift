//
//  UserType.swift
//  Domain
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public enum UserType {
    case explorer
    case walker
    case lifeCreator
    case aesthete

    public init?(
        activityStyle: ActivityStyle?,
        engagementLevel: EngagementLevel?
    ) {
        guard let activityStyle, let engagementLevel else {
            return nil
        }

        self = switch (activityStyle, engagementLevel) {
        case (.outdoor, .active): .explorer
        case (.outdoor, .casual): .walker
        case (.indoor, .active): .lifeCreator
        case (.indoor, .casual): .aesthete
        }
    }

    public var name: String {
        switch self {
        case .explorer: "제철을 쫓는 탐험가"
        case .walker: "일상 속 제철 산책가"
        case .lifeCreator: "제철을 채우는 라이프 크리에이터"
        case .aesthete: "제철을 음미하는 감상가"
        }
    }
}
