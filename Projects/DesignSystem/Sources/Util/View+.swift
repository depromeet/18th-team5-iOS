//
//  View+.swift
//  DesignSystem
//
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public extension View {
    func sheetCornerRadius() -> some View {
        if #available(iOS 26.0, *) {
            self.presentationCornerRadius(nil)
        } else {
            self.presentationCornerRadius(.radius24)
        }
    }
}
