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
    private let cards: [CardModel] = (0 ..< 10).map { CardModel(id: $0, color: .random()) }

    var body: some View {
        CardStackView(items: cards) { card in
            card.color
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
