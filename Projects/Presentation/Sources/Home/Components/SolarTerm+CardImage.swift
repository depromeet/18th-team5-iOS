//
//  SolarTerm+CardImage.swift
//  Presentation
//
//  Created by 송민교 on 6/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

extension SolarTerm {
    var cardImage: Image {
        switch self {
        case .ibha: .imgIbhaHomeCard
        case .soman: .imgSomanHomeCard
        case .mangjong: .imgMangjongHomeCard
        case .haji: .imgHajiHomeCard
        case .soseo: .imgSoseoHomeCard
        case .daeseo: .imgDaeseoHomeCard
        default: .imgSolarTermCardDefault
        }
    }
}
