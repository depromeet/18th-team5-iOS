//
//  LinearGradient+.swift
//  DesignSystem
//
//  Created by 이정원 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public extension LinearGradient {
    static let onboardingBackground: Self = .init(
        stops: [
            .init(color: Color.green50, location: 0.0),
            .init(color: .white, location: 0.5)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
  
    static let missionRecordBackground: Self = .init(
        stops: [
            .init(color: Color.green50, location: 0.0),
            .init(color: Color.gray50, location: 0.5)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let homeBackground: Self = .init(
        colors: [Color.green50, Color.gray50],
        startPoint: .top,
        endPoint: .bottom
    )
}
