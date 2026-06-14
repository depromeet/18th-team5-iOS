//
//  CardCountBadge.swift
//  Presentation
//
//  Created by choijunios on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

/// 카드 스택 위에 표시되는 현재/전체 개수 뱃지 ("1/6").
struct CardCountBadge: View {
    let current: Int
    let total: Int

    var body: some View {
        Text("\(current)/\(total)")
            .font(.body2Medium)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .background(Color.blackAlpha300)
            .clipShape(Capsule())
    }
}

#Preview {
    ZStack {
        Color.green500.ignoresSafeArea()
        CardCountBadge(current: 1, total: 6)
    }
}
