//
//  MissionCardNavigation+.swift
//  Data
//
//  Created by Codex on 6/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension MissionCardNavigationMethod {
    var analyticsValue: String {
        switch self {
        case .tab: "tab"
        case .indicator: "indicator"
        case .scroll: "scroll"
        }
    }
}

extension MissionCardNavigationDirection {
    var analyticsValue: String {
        switch self {
        case .next: "next"
        case .previous: "prev"
        }
    }
}
