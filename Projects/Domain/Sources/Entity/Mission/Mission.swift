//
//  Mission.swift
//  Domain
//
//  Created by 이정원 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct Mission: Equatable {
    public let title: String
    public let category: MissionCategory
    public let isCompleted: Bool
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
