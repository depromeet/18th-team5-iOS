//
//  LinearGradient+.swift
//  DesignSystem
//
//  Created by 이정원 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public extension LinearGradient {
    static func onboardingBackground(_ color: Color) -> Self {
        .init(
            stops: [
                .init(color: color, location: 0.0),
                .init(color: .white, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func missionRecordBackground(_ color: Color) -> Self {
        .init(
            stops: [
                .init(color: color, location: 0.0),
                .init(color: Color.gray50, location: 0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func homeBackground(_ color: Color) -> Self {
        .init(
            colors: [color, Color.gray50],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
