//
//  BottomButton.swift
//  DesignSystem
//
//  Created by 이정원 on 5/24/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct BottomButton: View {
    @Environment(\.isEnabled) private var isEnabled
    private let title: String
    private let action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body1Medium)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(Color.white)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: .radius12))
        }
    }
}

private extension BottomButton {
    @ViewBuilder
    var background: some View {
        if isEnabled {
            primaryGradient
        } else {
            Color.gray400
        }
    }

    var primaryGradient: some View {
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
