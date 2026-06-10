//
//  CustomAlertModifier.swift
//  DesignSystem
//
//  Created by 진준호 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

struct CustomAlertModifier<ID: Hashable>: ViewModifier {
    let isPresented: Bool
    let icon: Image?
    let message: String
    let buttons: [CustomAlertButton<ID>]
    let onAlertButtonTapped: (ID) -> Void

    func body(content: Content) -> some View {
        let shouldPresent = isPresented && !buttons.isEmpty

        ZStack {
            content
                .allowsHitTesting(!shouldPresent)
                .accessibilityHidden(shouldPresent)

            if shouldPresent {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()

                    CustomAlertView(
                        icon: icon,
                        message: message,
                        buttons: buttons,
                        onAlertButtonTapped: onAlertButtonTapped
                    )
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }
}

public extension View {
    func customAlert<ID: Hashable>(
        isPresented: Bool,
        icon: Image? = nil,
        message: String,
        buttons: [CustomAlertButton<ID>],
        onAlertButtonTapped: @escaping (ID) -> Void
    ) -> some View {
        modifier(
            CustomAlertModifier<ID>(
                isPresented: isPresented,
                icon: icon,
                message: message,
                buttons: buttons,
                onAlertButtonTapped: onAlertButtonTapped
            )
        )
    }
}
