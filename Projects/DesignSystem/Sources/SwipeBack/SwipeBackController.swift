//
//  SwipeBackController.swift
//  DesignSystem
//
//  Created by 이정원 on 6/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI
import UIKit

private struct SwipeBackController: UIViewControllerRepresentable {
    let isEnabled: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.update(from: uiViewController, isEnabled: isEnabled)
    }

    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.detach()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        private weak var navigationController: UINavigationController?
        private weak var screen: UIViewController?

        func update(from markerViewController: UIViewController, isEnabled: Bool) {
            guard let navigationController = markerViewController.navigationController else { return }
            guard let screen = markerViewController.navigationStackScreen(in: navigationController) else { return }

            let isDifferent = self.navigationController !== navigationController || self.screen !== screen
            if isDifferent { detach() }

            self.navigationController = navigationController
            self.screen = screen
            SwipeBackGestureDelegate.set(isEnabled, for: screen, in: navigationController)
        }

        func detach() {
            if let navigationController, let screen {
                SwipeBackGestureDelegate.remove(screen, from: navigationController)
            }

            self.navigationController = nil
            self.screen = nil
        }
    }
}

private extension UIViewController {
    func navigationStackScreen(in navigationController: UINavigationController) -> UIViewController? {
        return sequence(first: self) { $0.parent }
            .first { viewController in
                navigationController.viewControllers.contains { $0 === viewController }
            }
    }
}

public extension View {
    func swipeBackEnabled(isEnabled: Bool = true) -> some View {
        background(
            SwipeBackController(isEnabled: isEnabled)
                .frame(width: 0, height: 0)
        )
    }
}
