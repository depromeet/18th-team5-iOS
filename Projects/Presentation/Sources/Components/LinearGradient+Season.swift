//
//  LinearGradient+Season.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

extension LinearGradient {
    static func background(_ season: Season) -> Self {
        .init(
            stops: [
                .init(color: season.color(.scale50), location: 0.0),
                .init(color: .white, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func homeCardBackground(_ season: Season) -> Self {
        .init(
            stops: [
                .init(color: season.color(.scale300), location: 0.0),
                .init(color: season.color(.scale400).opacity(0), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
