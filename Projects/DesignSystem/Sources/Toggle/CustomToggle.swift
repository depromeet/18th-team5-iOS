//
//  CustomToggle.swift
//  DesignSystem
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct CustomToggle: View {
    @Environment(\.isEnabled) private var isEnabled
    @Binding private var isOn: Bool
    private let mainColor: Color

    public init(
        isOn: Binding<Bool>,
        mainColor: Color
    ) {
        self._isOn = isOn
        self.mainColor = mainColor
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            Capsule()
                .frame(width: 46, height: 28)
                .foregroundColor(backgroundColor)

            Circle()
                .frame(width: 22, height: 22)
                .foregroundColor(thumbColor)
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 0)
                .padding(3)
        }
        .animation(.spring(duration: 0.3), value: isOn)
        .sensoryFeedback(.impact(weight: .heavy), trigger: isOn)
        .onTapGesture { isOn.toggle() }
        .gesture(dragGesture)
    }
}

private extension CustomToggle {
    var alignment: Alignment {
        isOn ? .trailing : .leading
    }

    var backgroundColor: Color {
        guard isEnabled else { return .gray400 }
        return isOn ? mainColor : .gray200
    }

    var thumbColor: Color {
        isEnabled ? .white : .gray200
    }
}

private extension CustomToggle {
    var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                let width = value.predictedEndTranslation.width
                guard abs(width) >= 40 else { return }
                let isOn = width > 0
                self.isOn = isOn
            }
    }
}
