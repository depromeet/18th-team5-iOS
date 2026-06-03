//
//  SearchMissionButton.swift
//  Presentation
//
//  Created by 이정원 on 5/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct SearchMissionButton: View {
    @Environment(\.isEnabled) private var isEnabled
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(backgroundColor)
                    .overlay(Circle().stroke(borderColor))

                Image.icStar
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(iconColor)
            }
        }
        .disabled(!isEnabled)
    }
}

private extension SearchMissionButton {
    var iconColor: Color {
        isEnabled ? .gray800 : .white
    }

    var backgroundColor: Color {
        isEnabled ? .gray100 : .gray400
    }

    var borderColor: Color {
        isEnabled ? .gray300 : .clear
    }
}
