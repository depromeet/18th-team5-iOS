//
//  FontViewModifier.swift
//  DesignSystem
//
//  Created by 이정원 on 5/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

struct FontViewModifier: ViewModifier {
    private let family: FontFamily
    private let size: CGFloat
    private let weight: FontWeight
    private let lineHeight: CGFloat

    init(family: FontFamily, typography: Typography) {
        self.family = family
        self.size = typography.style.size
        self.weight = typography.weight
        self.lineHeight = typography.style.lineHeight
    }

    init(
        family: FontFamily,
        size: CGFloat,
        weight: FontWeight,
        lineHeight: CGFloat
    ) {
        self.family = family
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
    }

    func body(content: Content) -> some View {
        content
            .font(family.swiftUIFont(size, weight))
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }
}

private extension FontViewModifier {
    var lineSpacing: CGFloat {
        let defaultLineHeight = family.uiFont(size, weight).lineHeight
        return lineHeight - defaultLineHeight
    }
}

public extension View {
    func font(_ typography: Typography) -> some View {
        modifier(FontViewModifier(family: .pretendard, typography: typography))
    }

    func font(size: CGFloat, weight: FontWeight, lineHeight: CGFloat) -> some View {
        modifier(FontViewModifier(
            family: .pretendard,
            size: size,
            weight: weight,
            lineHeight: lineHeight
        ))
    }
}
