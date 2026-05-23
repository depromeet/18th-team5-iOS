//
//  CustomAlertView.swift
//  DesignSystem
//
//  Created by 진준호 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public enum CustomAlertButtonStyle {
    case primary
    case secondary
}

public struct CustomAlertButton {
    public let title: String
    public let style: CustomAlertButtonStyle
    public let action: () -> Void

    public init(title: String, style: CustomAlertButtonStyle, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
}

struct CustomAlertView: View {
    private let icon: Image?
    private let message: String
    private let buttons: [CustomAlertButton]

    init(
        icon: Image? = nil,
        message: String,
        buttons: [CustomAlertButton]
    ) {
        self.icon = icon
        self.message = message
        self.buttons = buttons
    }

    var body: some View {
        VStack(spacing: 0) {
            if let icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 12)
            }

            Text(message)
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)

            buttonArea
        }
        .padding(EdgeInsets(top: 28, leading: 20, bottom: 20, trailing: 20))
        .background(Color.white)
        .clipShape(.rect(cornerRadius: .radius16))
        .padding(.horizontal, 28)
    }

    @ViewBuilder
    private var buttonArea: some View {
        if buttons.count == 1, let button = buttons.first {
            alertButton(button)
        } else {
            HStack(spacing: 10) {
                ForEach(buttons.indices, id: \.self) { index in
                    alertButton(buttons[index])
                }
            }
        }
    }

    private func alertButton(_ button: CustomAlertButton) -> some View {
        Button(action: button.action) {
            Text(button.title)
                .font(.body1Medium)
                .foregroundStyle(button.style.foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(button.style.background)
                .clipShape(.rect(cornerRadius: .radius12))
        }
    }
}

private extension CustomAlertButtonStyle {
    @ViewBuilder
    var background: some View {
        switch self {
        case .primary:
            EllipticalGradient(
                stops: [
                    .init(color: .gray800, location: 0.0),
                    .init(color: .clear, location: 1.0)
                ],
                center: .center
            )
            .background(Color.gray700)
        case .secondary:
            Color.gray200
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary: Color.gray50
        case .secondary: Color.gray900
        }
    }
}

#Preview("Single Button") {
    ZStack {
        Color.black.opacity(0.6).ignoresSafeArea()
        CustomAlertView(
            message: "기록이 저장되었어요",
            buttons: [
                CustomAlertButton(title: "확인", style: .primary) {}
            ]
        )
    }
}

#Preview("Two Buttons with Icon") {
    ZStack {
        Color.black.opacity(0.6).ignoresSafeArea()
        CustomAlertView(
            icon: Image(systemName: "camera.fill"),
            message: "미션 기록 사진을 찍기 위해서\n카메라 접근 권한이 필요해요.",
            buttons: [
                CustomAlertButton(title: "취소", style: .secondary) {},
                CustomAlertButton(title: "확인", style: .primary) {}
            ]
        )
    }
}
