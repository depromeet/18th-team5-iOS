//
//  LoadingViewModifier.swift
//  DesignSystem
//
//  Created by 이정원 on 5/9/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

struct LoadingViewModifier: ViewModifier {
    private let isLoading: Bool

    init(isLoading: Bool) {
        self.isLoading = isLoading
    }

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)

            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}

public extension View {
    func loading(isLoading: Bool) -> some View {
        modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
