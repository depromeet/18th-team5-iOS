//
//  Season+ButtonStyle.swift
//  Presentation
//
//  Created by 송민교 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

extension ButtonStyle where Self == SeasonGradientButtonStyle {
    static func seasonGradient(_ season: Season) -> SeasonGradientButtonStyle {
        SeasonGradientButtonStyle(
            startColor: season.color(.scale400),
            endColor: season.color(.scale600)
        )
    }
}
