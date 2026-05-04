//
//  Color+.swift
//  DesignSystem
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public extension Color {
    init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self = Color(UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
}
