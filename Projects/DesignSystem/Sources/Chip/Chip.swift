//
//  Chip.swift
//  DesignSystem
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct Chip: View {
    public enum ChipType {
        case `default`
        case secondary
    }

    private let title: String
    private let type: ChipType
    private let action: () -> Void

    public init(
        title: String,
        type: ChipType = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(typography)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .frame(height: 36)
                .background { background }
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private extension Chip {
    var typography: Typography {
        switch type {
        case .default: .body2Medium
        case .secondary: .body2Regular
        }
    }

    var textColor: Color {
        switch type {
        case .default: .gray50
        case .secondary: .gray900
        }
    }

    @ViewBuilder
    var background: some View {
        switch type {
        case .default: defaultGradient
        case .secondary: Color.gray100
        }
    }

    var defaultGradient: some View {
        EllipticalGradient(
            stops: [
                .init(color: .gray800, location: 0.0),
                .init(color: .clear, location: 1.0)
            ],
            center: .center
        )
        .background(Color.gray700)
    }
}
