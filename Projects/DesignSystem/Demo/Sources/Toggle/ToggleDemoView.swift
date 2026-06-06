//
//  ToggleDemoView.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct ToggleDemoView: View {
    @State private var isOn: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            CustomToggle(isOn: $isOn, mainColor: .green600)

            CustomToggle(isOn: .constant(true), mainColor: .green600)
                .disabled(true)

            CustomToggle(isOn: .constant(false), mainColor: .green600)
                .disabled(true)
        }
    }
}
