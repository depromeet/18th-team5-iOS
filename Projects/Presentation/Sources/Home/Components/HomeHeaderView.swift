//
//  HomeHeaderView.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 47) // Status bar

            HStack {
                Text("peaktime")
                    .font(.title2Medium)
                    .foregroundStyle(Color(hex: 0x111111).opacity(0.23))

                Spacer()

                Button(action: {}) {
                    Image(systemName: "bell")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray900)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    HomeHeaderView()
}
