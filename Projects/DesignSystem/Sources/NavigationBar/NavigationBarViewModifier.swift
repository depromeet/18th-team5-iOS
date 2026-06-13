//
//  NavigationBarViewModifier.swift
//  DesignSystem
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct NavigationBarViewModifier: ViewModifier {
    public enum DismissType {
        case back
        case close
    }

    private let title: String
    private let dismissType: DismissType
    private let shouldBlur: Bool
    private let action: () -> Void

    init(
        title: String,
        dismissType: DismissType,
        shouldBlur: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.shouldBlur = shouldBlur
        self.dismissType = dismissType
        self.action = action
    }

    public func body(content: Content) -> some View {
        VStack(spacing: 0) {
            navigationBar
            content
        }
    }
}

private extension NavigationBarViewModifier {
    var navigationBar: some View {
        ZStack {
            Text(title)
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                backButton
                Spacer()
                closeButton
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
        .background {
            if shouldBlur {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
        }
    }

    var backButton: some View {
        Button(action: action) {
            Image.icArrowLeft
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray800)
        }
        .renderedIf(dismissType == .back)
    }

    var closeButton: some View {
        Button(action: action) {
            Image.icClose
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray800)
        }
        .renderedIf(dismissType == .close)
    }
}

public extension View {
    func navigationBar(
        title: String,
        dismissType: NavigationBarViewModifier.DismissType = .back,
        shouldBlur: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        modifier(NavigationBarViewModifier(
            title: title,
            dismissType: dismissType,
            shouldBlur: shouldBlur,
            action: action
        ))
        .navigationBarBackButtonHidden()
    }
}
