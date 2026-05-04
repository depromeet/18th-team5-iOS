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
    case font

    var name: String {
        switch self {
        case .carousel: "Carousel"
        case .circularWheelPicker: "Circular Wheel Picker"
        case .font: "Font"
        }
    }
}
