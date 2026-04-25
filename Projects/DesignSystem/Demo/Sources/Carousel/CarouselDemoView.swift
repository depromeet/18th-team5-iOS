//
//  CarouselDemoView.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct CarouselDemoView: View {
    var body: some View {
        VStack(spacing: 0) {
            carousel
            button
                .padding(.top, 32)
        }
        .navigationTitle("Carousel")
    }
}

private extension CarouselDemoView {
    var carousel: some View {
        Carousel(
            items: Array(0 ..< 6),
            spacing: 16,
            aspectRatio: 2.0 / 3.0
        ) { _ in
            Color.gray
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    var button: some View {
        Button {} label: {
            Text("자세히 보기")
                .frame(width: 144, height: 50)
                .foregroundStyle(Color.white)
                .background(Color.mint)
                .clipShape(Capsule())
        }
    }
}
