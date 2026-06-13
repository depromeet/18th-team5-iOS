//
//  NewCustomAlertView.swift
//  DesignSystem
//
//  Created by 이정원 on 6/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct NewCustomAlertView: View {
    private let icon: Image?
    private let title: String
    private let primaryButtonTitle: String
    private let secondaryButtonTitle: String?
    private let primaryAction: () -> Void
    private let secondaryAction: (() -> Void)?

    public init(
        alertInfo: AlertInfo,
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.icon = alertInfo.icon
        self.title = alertInfo.title
        self.primaryButtonTitle = alertInfo.primaryButtonTitle
        self.secondaryButtonTitle = alertInfo.secondaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    public var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                iconView
                textView
            }

            HStack(spacing: 10) {
                secondaryButton
                primaryButton
            }
        }
        .padding(.top, 28)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
        .shadow(color: .blackAlpha300, radius: 16, x: 0, y: 8)
        .padding(.horizontal, 32)
    }
}

private extension NewCustomAlertView {
    @ViewBuilder
    var iconView: some View {
        if let icon {
            icon
                .resizable()
                .frame(width: 40, height: 40)
        }
    }

    var textView: some View {
        Text(title)
            .font(.body1Medium)
            .foregroundStyle(Color.gray900)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var secondaryButton: some View {
        if let secondaryButtonTitle, let secondaryAction {
            Button(action: secondaryAction) {
                Text(secondaryButtonTitle)
                    .font(.body1Medium)
                    .foregroundStyle(Color.gray900)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.gray200)
                    .clipShape(RoundedRectangle(cornerRadius: .radius12))
            }
        }
    }

    var primaryButton: some View {
        Button(action: primaryAction) {
            Text(primaryButtonTitle)
                .font(.body1Medium)
                .foregroundStyle(Color.gray50)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background { EllipticalGradient.buttonBackground }
                .background(Color.gray700)
                .clipShape(RoundedRectangle(cornerRadius: .radius12))
        }
    }
}
