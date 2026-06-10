//
//  AlertInfo.swift
//  DesignSystem
//
//  Created by 이정원 on 6/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct AlertInfo {
    public let icon: Image?
    public let title: String
    public let primaryButtonTitle: String
    public let secondaryButtonTitle: String?

    public init(
        icon: Image? = nil,
        title: String,
        buttonTitle: String
    ) {
        self.icon = icon
        self.title = title
        self.primaryButtonTitle = buttonTitle
        self.secondaryButtonTitle = nil
    }

    public init(
        icon: Image? = nil,
        title: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String
    ) {
        self.icon = icon
        self.title = title
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
    }
}
