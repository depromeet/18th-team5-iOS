//
//  FontStyle.swift
//  DesignSystem
//
//  Created by 이정원 on 5/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

enum FontStyle {
    case largeTitle1
    case largeTitle2
    case largeTitle3
    case largeTitle4

    case title1
    case title2

    case headline1
    case headline2

    case body1
    case body2

    case caption1
    case caption2
}

extension FontStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle1: 32
        case .largeTitle2: 30
        case .largeTitle3: 28
        case .largeTitle4: 26
        case .title1: 24
        case .title2: 22
        case .headline1: 20
        case .headline2: 18
        case .body1: 16
        case .body2: 14
        case .caption1: 12
        case .caption2: 11
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .largeTitle1: 48
        case .largeTitle2: 45
        case .largeTitle3: 42
        case .largeTitle4: 39
        case .title1: 32
        case .title2: 30
        case .headline1: 28
        case .headline2: 26
        case .body1: 24
        case .body2: 20
        case .caption1: 18
        case .caption2: 16
        }
    }
}
