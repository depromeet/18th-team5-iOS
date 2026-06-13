//
//  FontFamily.swift
//  DesignSystem
//
//  Created by 이정원 on 5/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI
import UIKit

private typealias Pretendard = DesignSystemFontFamily.Pretendard

enum FontFamily {
    case pretendard
}

extension FontFamily {
    func uiFont(_ size: CGFloat, _ weight: FontWeight) -> UIFont {
        font(weight).font(size: size)
    }

    func swiftUIFont(_ size: CGFloat, _ weight: FontWeight) -> SwiftUI.Font {
        font(weight).swiftUIFont(size: size)
    }
}

private extension FontFamily {
    func font(_ weight: FontWeight) -> DesignSystemFontConvertible {
        switch self {
        case .pretendard:
            switch weight {
            case .bold: Pretendard.bold
            case .semibold: Pretendard.semiBold
            case .medium: Pretendard.medium
            case .regular: Pretendard.regular
            }
        }
    }
}
