//
//  Typography.swift
//  DesignSystem
//
//  Created by 송민교 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

// MARK: - FontStyle

public struct FontStyle {
    private let size: CGFloat
    public let lineSpacing: CGFloat

    public var light: Font {
        DesignSystemFontFamily.Pretendard.light.swiftUIFont(size: size)
    }

    public var regular: Font {
        DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: size)
    }

    public var medium: Font {
        DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: size)
    }

    public var semiBold: Font {
        DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: size)
    }

    public var bold: Font {
        DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: size)
    }

    init(size: CGFloat, lineHeight: CGFloat) {
        self.size = size
        self.lineSpacing = lineHeight - size
    }
}

// MARK: - Typography Tokens

public extension FontStyle {
    static let largeTitle1 = FontStyle(size: 32, lineHeight: 48)
    static let largeTitle2 = FontStyle(size: 30, lineHeight: 45)
    static let largeTitle3 = FontStyle(size: 28, lineHeight: 42)
    static let largeTitle4 = FontStyle(size: 26, lineHeight: 39)

    static let title1 = FontStyle(size: 24, lineHeight: 32)
    static let title2 = FontStyle(size: 22, lineHeight: 30)

    static let headline1 = FontStyle(size: 20, lineHeight: 28)
    static let headline2 = FontStyle(size: 18, lineHeight: 26)

    static let body1 = FontStyle(size: 16, lineHeight: 24)
    static let body2 = FontStyle(size: 14, lineHeight: 20)

    static let caption1 = FontStyle(size: 12, lineHeight: 18)
    static let caption2 = FontStyle(size: 11, lineHeight: 16)
}

// MARK: - View Extension

public extension View {
    func font(_ style: FontStyle, _ weight: KeyPath<FontStyle, Font>) -> some View {
        self
            .font(style[keyPath: weight])
            .lineSpacing(style.lineSpacing)
    }
}
