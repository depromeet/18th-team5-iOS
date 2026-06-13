//
//  EllipticalGradient+.swift
//  DesignSystem
//
//  Created by 진준호 on 6/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public extension EllipticalGradient {
    static let buttonBackground: Self = .init(
        stops: [
            .init(color: .gray800, location: 0.0),
            .init(color: .clear, location: 1.0)
        ],
        center: .center
    )
}
