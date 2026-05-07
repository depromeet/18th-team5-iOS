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
            .init(color: .init(hex: 0xECFBF3), location: 0.0),
            .init(color: .white, location: 0.4)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
