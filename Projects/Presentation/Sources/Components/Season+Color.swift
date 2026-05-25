//
//  Season+Color.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

extension Season {
    enum ColorScale {
        case scale50
        case scale100
        case scale200
        case scale300
        case scale400
        case scale500
        case scale600
        case scale700
        case scale800
        case scale900
    }

    func color(_ scale: ColorScale) -> Color {
        switch (self, scale) {
        case (.spring, .scale50): .pink50
        case (.spring, .scale100): .pink100
        case (.spring, .scale200): .pink200
        case (.spring, .scale300): .pink300
        case (.spring, .scale400): .pink400
        case (.spring, .scale500): .pink500
        case (.spring, .scale600): .pink600
        case (.spring, .scale700): .pink700
        case (.spring, .scale800): .pink800
        case (.spring, .scale900): .pink900
        case (.summer, .scale50): .green50
        case (.summer, .scale100): .green100
        case (.summer, .scale200): .green200
        case (.summer, .scale300): .green300
        case (.summer, .scale400): .green400
        case (.summer, .scale500): .green500
        case (.summer, .scale600): .green600
        case (.summer, .scale700): .green700
        case (.summer, .scale800): .green800
        case (.summer, .scale900): .green900
        case (.autumn, .scale50): .orange50
        case (.autumn, .scale100): .orange100
        case (.autumn, .scale200): .orange200
        case (.autumn, .scale300): .orange300
        case (.autumn, .scale400): .orange400
        case (.autumn, .scale500): .orange500
        case (.autumn, .scale600): .orange600
        case (.autumn, .scale700): .orange700
        case (.autumn, .scale800): .orange800
        case (.autumn, .scale900): .orange900
        case (.winter, .scale50): .blue50
        case (.winter, .scale100): .blue100
        case (.winter, .scale200): .blue200
        case (.winter, .scale300): .blue300
        case (.winter, .scale400): .blue400
        case (.winter, .scale500): .blue500
        case (.winter, .scale600): .blue600
        case (.winter, .scale700): .blue700
        case (.winter, .scale800): .blue800
        case (.winter, .scale900): .blue900
        }
    }
}
