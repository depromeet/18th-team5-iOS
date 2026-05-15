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
    private let typography: Typography

    init(family: FontFamily, typography: Typography) {
        self.family = family
        self.typography = typography
    }

    func body(content: Content) -> some View {
        content
            .font(family.swiftUIFont(typography))
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }
}

private extension FontViewModifier {
    var lineSpacing: CGFloat {
        let defaultLineHeight = family.uiFont(typography).lineHeight
        return typography.style.lineHeight - defaultLineHeight
    }
}

public extension Text {
    func font(_ typography: Typography) -> some View {
        modifier(FontViewModifier(family: .pretendard, typography: typography))
    }
}

public extension View {
    func font(_ typography: Typography) -> some View {
        modifier(FontViewModifier(family: .pretendard, typography: typography))
    }
}
