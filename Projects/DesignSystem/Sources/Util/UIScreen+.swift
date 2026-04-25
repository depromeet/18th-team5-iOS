//
//  UIScreen+.swift
//  DesignSystem
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import UIKit

public extension UIScreen {
    private static var windowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
    }

    static let width: CGFloat = windowScene?.screen.bounds.width ?? 0
    static let height: CGFloat = windowScene?.screen.bounds.height ?? 0
}
