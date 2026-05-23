//
//  WeekdayLabelRow.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct WeekdayLabelRow: View {
    let labels = ["월", "화", "수", "목", "금", "토", "일"]
    var body: some View {
        HStack(spacing: 7) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.caption2Medium)
                    .foregroundStyle(Color.gray400)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
