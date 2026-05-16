//
//  BackgroundBlurView.swift
//  DesignSystem
//
//  Created by 송민교 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI
import UIKit

public struct BackgroundBlurView: UIViewRepresentable {
    private let style: UIBlurEffect.Style

    public init(style: UIBlurEffect.Style = .systemUltraThinMaterialLight) {
        self.style = style
    }

    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.isUserInteractionEnabled = false
        return view
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
