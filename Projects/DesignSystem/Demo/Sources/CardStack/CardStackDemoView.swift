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
        ZStack {
            Color.clear
            cardStack
            navigateButtons
        }
        .navigationTitle("Card Stack")
    }

    var cardStack: some View {
        CardStackView(
            topCardIndex: $topCardIndex,
            items: cards
        ) {
            $0.color
        }
    }

    var navigateButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Button("다음") {
                        withAnimation {
                            topCardIndex += 1
                        }
                    }
                    .disabled(topCardIndex == cards.endIndex - 1)

                    Button("이전") {
                        withAnimation {
                            topCardIndex -= 1
                        }
                    }
                    .disabled(topCardIndex == 0)
                }
                .padding([.trailing, .bottom], 30)
            }
        }
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
