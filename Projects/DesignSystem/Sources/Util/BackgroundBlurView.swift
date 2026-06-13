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

public struct CustomBackdropBlurView: UIViewRepresentable {
    private let fraction: CGFloat

    public init(radius: CGFloat = 10) {
        self.fraction = min(radius / 30.0, 1.0)
    }

    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear

        let animator = UIViewPropertyAnimator()
        animator.addAnimations {
            view.effect = UIBlurEffect(style: .light)
        }
        animator.fractionComplete = fraction
        animator.pausesOnCompletion = true
        context.coordinator.animator = animator

        return view
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        context.coordinator.animator?.fractionComplete = fraction
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator {
        var animator: UIViewPropertyAnimator?

        deinit {
            animator?.stopAnimation(true)
        }
    }
}
