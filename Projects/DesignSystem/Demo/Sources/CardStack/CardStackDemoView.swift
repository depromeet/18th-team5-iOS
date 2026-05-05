//
//  CardStackDemoView.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

private struct CardModel: Identifiable, Hashable {
    let id: Int
    let color: Color
}

struct CardStackDemoView: View {
    @State private var topCardIndex: Int = 0

    private let cards: [CardModel] = (0 ..< 10).map {
        CardModel(id: $0, color: .random())
    }

    var body: some View {
        CardStackView(
            topCardIndex: $topCardIndex,
            items: cards
        ) {
            $0.color
        }
        .navigationTitle("Card Stack")
    }
}

private extension Color {
    static func random() -> Color {
        Color(
            red: .random(in: 0.3 ... 1.0),
            green: .random(in: 0.3 ... 1.0),
            blue: .random(in: 0.3 ... 1.0)
        )
    }
}
