//
//  MasterButtonStyle.swift
//  DesignSystem
//
//  Created by choijunios on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public extension ButtonStyle where Self == MasterButtonStyle {
    static func master(_ size: MasterButtonStyle.Size) -> MasterButtonStyle {
        MasterButtonStyle(size: size)
    }
}

public struct MasterButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let size: Size

    public func makeBody(configuration: Configuration) -> some View {
        let state = state(configuration)
        return configuration.label
            .font(size.typography)
            .foregroundStyle(state.foregroundColor)
            .padding(.vertical, size.verticalPadding)
            .frame(minWidth: 50, maxWidth: .infinity)
            .background { backgroundView(state) }
            .mask { maskView(size) }
    }
}

private extension MasterButtonStyle {
    func state(_ configuration: Configuration) -> State {
        guard isEnabled else { return .disabled }
        return configuration.isPressed ? .secondary : .default
    }

    @ViewBuilder
    func backgroundView(_ state: State) -> some View {
        switch state {
        case .default:
            Color.gray700
                .overlay {
                    RadialGradient(
                        colors: [
                            .gray800,
                            .gray800.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                }
        case .secondary:
            Color.gray200
        case .disabled:
            Color.gray400
        }
    }

    @ViewBuilder
    func maskView(_ size: Size) -> some View {
        switch size.cornerRadius {
        case .capsule:
            Capsule()
        case let .fixed(radius):
            RoundedRectangle(cornerRadius: radius)
        }
    }
}

// MARK: Size & State

public extension MasterButtonStyle {
    struct Size {
        let verticalPadding: CGFloat
        let cornerRadius: CornerRadius
        let typography: Typography

        public static let small = Size(
            verticalPadding: 6,
            cornerRadius: .capsule,
            typography: .body2Medium
        )

        public static let medium = Size(
            verticalPadding: 12,
            cornerRadius: .fixed(12),
            typography: .body1Medium
        )

        public static let large = Size(
            verticalPadding: 16,
            cornerRadius: .fixed(12),
            typography: .body1Medium
        )
    }

    enum CornerRadius {
        case fixed(CGFloat)
        case capsule
    }

    enum State {
        case `default`
        case secondary
        case disabled

        var foregroundColor: Color {
            switch self {
            case .default: .gray50
            case .secondary: .gray900
            case .disabled: .white
            }
        }
    }
}

#Preview {
    let sizes: [MasterButtonStyle.Size] = [
        .small, .medium, .large
    ]

    VStack {
        ForEach(sizes.indices) { _ in
            Button {} label: {
                Text("확인")
            }
            .buttonStyle(.master(.large))
        }

        ForEach(sizes.indices) {
            Button {} label: {
                Text("확인")
            }
            .buttonStyle(MasterButtonStyle(size: sizes[$0]))
            .disabled(true)
        }
    }
    .padding(.horizontal, 20)
}
