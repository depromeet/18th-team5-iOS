//
//  Mission.swift
//  Domain
//
//  Created by 이정원 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct Mission: Equatable, Hashable {
    public let id: Int
    public let title: String
    public let category: MissionCategory
    public let season: Season
    public let isCompleted: Bool

    public init(
        id: Int,
        title: String,
        category: MissionCategory,
        season: Season,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.season = season
        self.isCompleted = isCompleted
    }
}

public enum MissionCategory: CaseIterable {
    case food
    case contents
    case activity

    public var name: String {
        switch self {
        case .food: "음식"
        case .contents: "콘텐츠"
        case .activity: "활동"
        }
    }
}
