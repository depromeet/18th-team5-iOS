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
    var scrollOffset: CGFloat = 0

    private var showBlur: Bool {
        scrollOffset > 1
    }

    var body: some View {
        HStack {
            Image.imgPeaktimeHomeLogo
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
            if showBlur {
                BackgroundBlurView()
                    .ignoresSafeArea(edges: .top)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showBlur)
    }
}

#Preview {
    ZStack {
        LinearGradient.onboardingBackground
            .ignoresSafeArea()

        ScrollView {
            HomeHeaderView(scrollOffset: 0)
            Spacer()
        }
    }
}
