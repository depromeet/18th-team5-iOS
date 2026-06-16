//
//  SwipeBackGestureDelegate.swift
//  DesignSystem
//
//  Created by 이정원 on 6/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import UIKit

final class SwipeBackGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    private static var delegatesByNavigationID: [ObjectIdentifier: SwipeBackGestureDelegate] = [:]

    static func set(
        _ isEnabled: Bool,
        for screen: UIViewController,
        in navigationController: UINavigationController
    ) {
        let delegate = delegate(for: navigationController)
        delegate.isEnabledByScreenID[ObjectIdentifier(screen)] = isEnabled
        delegate.install()
    }

    static func remove(
        _ screen: UIViewController,
        from navigationController: UINavigationController
    ) {
        let navigationID = ObjectIdentifier(navigationController)
        let screenID = ObjectIdentifier(screen)
        delegatesByNavigationID[navigationID]?.isEnabledByScreenID[screenID] = nil
    }

    private static func delegate(for navigationController: UINavigationController) -> SwipeBackGestureDelegate {
        delegatesByNavigationID = delegatesByNavigationID.filter { $0.value.navigationController != nil }

        let navigationID = ObjectIdentifier(navigationController)
        if let delegate = delegatesByNavigationID[navigationID],
           delegate.navigationController === navigationController {
            return delegate
        }

        let delegate = SwipeBackGestureDelegate(navigationController: navigationController)
        delegatesByNavigationID[navigationID] = delegate
        return delegate
    }

    private weak var navigationController: UINavigationController?
    private var isEnabledByScreenID: [ObjectIdentifier: Bool] = [:]

    private init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    private func install() {
        guard let gestureRecognizer = navigationController?.interactivePopGestureRecognizer else {
            return
        }

        gestureRecognizer.delegate = self
        gestureRecognizer.isEnabled = true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController else { return false }
        guard gestureRecognizer === navigationController.interactivePopGestureRecognizer else { return false }
        guard let topViewController = navigationController.topViewController else { return false }

        return navigationController.viewControllers.count > 1
            && isEnabledByScreenID[ObjectIdentifier(topViewController)] == true
    }
}
