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
        HStack {
            Image.peaktimeLogo
                .resizable()
                .frame(width: 140, height: 28)

            Spacer()

            Button(action: {}) {
                Image.bellEmptyAlarmIcon
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            BackgroundBlurView()
                .overlay(Color.white.opacity(0.1))
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.93),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: 0xECFBF3), .white],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()

        ScrollView {
            HomeHeaderView()
            Spacer()
        }
    }
}
