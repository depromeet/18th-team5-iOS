//
//  SeasonGradientButtonStyle.swift
//  DesignSystem
//
//  Created by 송민교 on 6/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct SeasonGradientButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    private let startColor: Color
    private let endColor: Color

    public init(startColor: Color, endColor: Color) {
        self.startColor = startColor
        self.endColor = endColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body1Medium)
            .foregroundStyle(Color.gray50)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(background(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: .radius12))
    }

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        if !isEnabled {
            Color.gray400
        } else if isPressed {
            LinearGradient(
                colors: [startColor.opacity(0.8), endColor.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            LinearGradient(
                colors: [startColor, endColor],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}
