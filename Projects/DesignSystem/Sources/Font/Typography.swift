//
//  Typography.swift
//  DesignSystem
//
//  Created by 송민교 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import UIKit

public enum Typography: CaseIterable {
    case largeTitle1Bold
    case largeTitle2Bold
    case largeTitle3Semibold
    case largeTitle4Semibold

    case title1Bold
    case title1Semibold
    case title1Medium
    case title1Regular
    case title2Bold
    case title2Semibold
    case title2Medium
    case title2Regular

    case headline1Semibold
    case headline1Medium
    case headline1Regular
    case headline2Semibold
    case headline2Medium
    case headline2Regular

    case body1Semibold
    case body1Medium
    case body1Regular
    case body2Semibold
    case body2Medium
    case body2Regular

    case caption1Semibold
    case caption1Medium
    case caption1Regular
    case caption2Semibold
    case caption2Medium
}

extension Typography {
    var style: FontStyle {
        switch self {
        case .largeTitle1Bold: .largeTitle1
        case .largeTitle2Bold: .largeTitle2
        case .largeTitle3Semibold: .largeTitle3
        case .largeTitle4Semibold: .largeTitle4
        case .title1Bold: .title1
        case .title1Semibold: .title1
        case .title1Medium: .title1
        case .title1Regular: .title1
        case .title2Bold: .title2
        case .title2Semibold: .title2
        case .title2Medium: .title2
        case .title2Regular: .title2
        case .headline1Semibold: .headline1
        case .headline1Medium: .headline1
        case .headline1Regular: .headline1
        case .headline2Semibold: .headline2
        case .headline2Medium: .headline2
        case .headline2Regular: .headline2
        case .body1Semibold: .body1
        case .body1Medium: .body1
        case .body1Regular: .body1
        case .body2Semibold: .body2
        case .body2Medium: .body2
        case .body2Regular: .body2
        case .caption1Semibold: .caption1
        case .caption1Medium: .caption1
        case .caption1Regular: .caption1
        case .caption2Semibold: .caption2
        case .caption2Medium: .caption2
        }
    }

    var weight: FontWeight {
        switch self {
        case .largeTitle1Bold: .bold
        case .largeTitle2Bold: .bold
        case .largeTitle3Semibold: .semibold
        case .largeTitle4Semibold: .semibold
        case .title1Bold: .bold
        case .title1Semibold: .semibold
        case .title1Medium: .medium
        case .title1Regular: .regular
        case .title2Bold: .bold
        case .title2Semibold: .semibold
        case .title2Medium: .medium
        case .title2Regular: .regular
        case .headline1Semibold: .semibold
        case .headline1Medium: .medium
        case .headline1Regular: .regular
        case .headline2Semibold: .semibold
        case .headline2Medium: .medium
        case .headline2Regular: .regular
        case .body1Semibold: .semibold
        case .body1Medium: .medium
        case .body1Regular: .regular
        case .body2Semibold: .semibold
        case .body2Medium: .medium
        case .body2Regular: .regular
        case .caption1Semibold: .semibold
        case .caption1Medium: .medium
        case .caption1Regular: .regular
        case .caption2Semibold: .semibold
        case .caption2Medium: .medium
        }
    }
}

public extension Typography {
    var uiFont: UIFont {
        FontFamily.pretendard.uiFont(style.size, weight)
    }
}
