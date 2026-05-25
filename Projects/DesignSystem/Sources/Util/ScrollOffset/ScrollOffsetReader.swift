//
//  ScrollOffsetReader.swift
//  DesignSystem
//
//  Created by 이정원 on 5/23/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

private struct ScrollOffsetReader: ViewModifier {
    private let onChange: (CGPoint) -> Void
    private let coordinateSpace = ScrollOffsetCoordinateSpace.scrollView

    init(onChange: @escaping (CGPoint) -> Void) {
        self.onChange = onChange
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: CGPoint(
                                x: -proxy.frame(in: .named(coordinateSpace)).minX,
                                y: -proxy.frame(in: .named(coordinateSpace)).minY
                            )
                        )
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .onPreferenceChange(
                ScrollOffsetPreferenceKey.self,
                perform: onChange
            )
    }
}

private enum ScrollOffsetCoordinateSpace {
    case scrollView
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

public extension View {
    func scrollOffsetCoordinateSpace() -> some View {
        coordinateSpace(name: ScrollOffsetCoordinateSpace.scrollView)
    }

    func readScrollOffset(
        onChange: @escaping (CGPoint) -> Void
    ) -> some View {
        modifier(ScrollOffsetReader(onChange: onChange))
    }
}
