//
//  Menu.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

enum Menu: CaseIterable {
    case carousel
    case circularWheelPicker
    case cardStack
    case font
    case toggle

    var name: String {
        switch self {
        case .carousel: "Carousel"
        case .circularWheelPicker: "Circular Wheel Picker"
        case .cardStack: "Card Stack"
        case .font: "Font"
        case .toggle: "Toggle"
        }
    }
}
