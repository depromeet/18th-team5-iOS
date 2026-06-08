//
//  MissionCategory.swift
//  Domain
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public enum MissionCategory: CaseIterable {
    case food
    case nature
    case content
    case place
    case music

    public var name: String {
        switch self {
        case .food: "음식"
        case .nature: "자연"
        case .content: "콘텐츠"
        case .place: "장소"
        case .music: "음악"
        }
    }
}
