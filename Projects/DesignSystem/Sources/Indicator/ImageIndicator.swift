//
//  ImageIndicator.swift
//  DesignSystem
//
//  Created by 송민교 on 6/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct ImageIndicator: View {
    private let count: Int
    private let current: Int
    private let activeColor: Color
    private let inactiveColor: Color

    public init(
        count: Int,
        current: Int,
        activeColor: Color = .white,
        inactiveColor: Color = .black.opacity(0.45)
    ) {
        self.count = count
        self.current = current
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0 ..< count, id: \.self) { index in
                Circle()
                    .fill(index == current ? activeColor : inactiveColor)
                    .frame(width: 5, height: 5)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
    }
}
