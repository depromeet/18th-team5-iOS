//
//  WeakFloatingButton.swift
//  DesignSystem
//
//  Created by choijunios on 6/10/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct WeakFloatingButton: View {
    public let style: Style
    public let onTap: () -> Void

    public init(style: Style, onTap: @escaping () -> Void) {
        self.style = style
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 2) {
                style.icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray800)
                    .frame(width: 20, height: 20)

                Text("이번 절기")
                    .font(.body2Medium)
                    .foregroundStyle(Color.gray900)
            }
            .padding(12)
            .background {
                Capsule()
                    .fill(.white)
                    .shadow(
                        color: Color.blackAlpha300,
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            }
        }
    }
}

public extension WeakFloatingButton {
    enum Style {
        case down, up
        var icon: Image {
            switch self {
            case .down: .iconArrowDown
            case .up: .iconArrowUp
            }
        }
    }
}
