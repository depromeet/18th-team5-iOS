//
//  OnboardingInitialView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct OnboardingInitialView: View {
    @State private var isFloating = false

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("잊히기 쉬운 계절의 찰나,")
                    .font(.body1Regular)
                    .foregroundStyle(Color.gray600)

                Text("지금 이 순간에만 할 수 있는\n제철 경험을 추천하고 기록해요")
                    .font(.title2Semibold)
                    .foregroundStyle(Color.gray800)
                    .multilineTextAlignment(.center)
            }

            imageView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1)
                    .repeatForever(autoreverses: true)
            ) {
                isFloating = true
            }
        }
    }
}

private extension OnboardingInitialView {
    var imageView: some View {
        ZStack(alignment: .bottom) {
            let deviceWidth = UIScreen.width
            let scaleRatio = deviceWidth / 375.0
            let cameraImageSize = scaleRatio * 200
            let bottomPaddingSize = scaleRatio * 31
            let floatOffset = scaleRatio * 20

            Image.imgSparkles
                .resizable()
                .scaledToFit()
                .frame(width: deviceWidth)

            Image.imgCamera
                .resizable()
                .frame(width: cameraImageSize, height: cameraImageSize)
                .padding(.bottom, bottomPaddingSize)
                .offset(y: isFloating ? -floatOffset : 0)
        }
    }
}
