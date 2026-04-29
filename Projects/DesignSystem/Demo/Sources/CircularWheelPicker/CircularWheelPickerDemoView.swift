//
//  CircularWheelPickerDemoView.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 4/27/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct CircularWheelPickerDemoView: View {
    @State private var index: Int = 11

    var body: some View {
        CircularWheelPicker(items: Array(0 ..< 24), selection: $index) { index in
            Text("봄의 첫 신호 포착하기 \(index + 1)")
                .frame(width: UIScreen.width - 48)
                .frame(height: 80)
                .background(Color(uiColor: .systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
