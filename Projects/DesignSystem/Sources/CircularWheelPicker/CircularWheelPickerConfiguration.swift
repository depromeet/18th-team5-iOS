//
//  CircularWheelPickerConfiguration.swift
//  DesignSystem
//
//  Created by 이정원 on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct CircularWheelPickerConfiguration {
    let contentLeadingInset: CGFloat
    let contentTrailingInset: CGFloat
    let contentHeight: CGFloat
    let rotationFrameLengthRatio: CGFloat
    let angleStep: Angle

    public init(
        contentLeadingInset: CGFloat,
        contentTrailingInset: CGFloat,
        contentHeight: CGFloat,
        rotationFrameLengthRatio: CGFloat,
        angleStep: Angle
    ) {
        self.contentLeadingInset = contentLeadingInset
        self.contentTrailingInset = contentTrailingInset
        self.contentHeight = contentHeight
        self.rotationFrameLengthRatio = rotationFrameLengthRatio
        self.angleStep = angleStep
    }

    public static var missionCard: Self {
        .init(
            contentLeadingInset: 20,
            contentTrailingInset: 58,
            contentHeight: 80,
            rotationFrameLengthRatio: 340.0 / 317.0,
            angleStep: .degrees(15)
        )
    }
}
