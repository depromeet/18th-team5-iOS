//
//  NavigationBarViewModifier.swift
//  DesignSystem
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

struct NavigationBarViewModifier: ViewModifier {
    private let title: String
    private let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    func body(content: Content) -> some View {
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
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
    }

    var backButton: some View {
        Button(action: action) {
            Image.icArrowLeft
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.gray800)
        }
    }
}

public extension View {
    func navigationBar(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        modifier(NavigationBarViewModifier(title: title, action: action))
    }
}
