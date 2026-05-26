//
//  MissionTheme.swift
//  Domain
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public enum MissionTheme: CaseIterable {
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
