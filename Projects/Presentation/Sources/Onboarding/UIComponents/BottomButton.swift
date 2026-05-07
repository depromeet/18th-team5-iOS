//
//  BottomButton.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct BottomButton: View {
    @Environment(\.isEnabled) private var isEnabled
    private let title: String
    private let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body2Medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(textColor)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

private extension BottomButton {
    var textColor: Color {
        isEnabled ? .init(hex: 0xF9FAFB) : .white
    }

    var backgroundColor: Color {
        isEnabled ? .init(hex: 0x1F2937) : .gray400
    }
}
