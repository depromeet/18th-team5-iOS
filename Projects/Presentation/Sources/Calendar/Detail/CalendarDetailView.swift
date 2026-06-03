//
//  CalendarDetailView.swift
//  Presentation
//
//  Created by choijunios on 6/3/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct CalendarDetailView: View {
    enum Constants {
        static let cardHorizontalPadding: CGFloat = 32.5
        static let cardRatio: CGFloat = 391 / 311
    }

    @State var frontCardIndex: Int = 0
    @State var screenSize: CGSize = .zero

    var body: some View {
        GeometryReader { _ in
            ZStack {
                backgroundView
                    .onGeometryChange(
                        for: CGSize.self,
                        of: { $0.size }
                    ) { screenSize = $0 }

                VStack {
                    CardStackView(
                        topCardIndex: $frontCardIndex,
                        items: [
                            DateCard(),
                            DateCard(),
                            DateCard(),
                            DateCard(),
                            DateCard(),
                            DateCard()
                        ]
                    ) { index, item in
                        let absoluteIndex = index - frontCardIndex
                        let cardWidth = max(screenSize.width - Constants.cardHorizontalPadding * 2, 0)

                        Group {
                            if absoluteIndex == 0 {
                                card(.content(item))
                            } else {
                                card(.placeholder(index: absoluteIndex))
                            }
                        }
                        .frame(
                            width: cardWidth,
                            height: cardWidth * Constants.cardRatio
                        )
                    }
                    .padding(.top, 16)
                    Spacer()
                }

                bottomButtonContainer
            }
        }
    }
}

// MARK: Card

private extension CalendarDetailView {
    enum CardType {
        case content(DateCard)
        case placeholder(index: Int)
    }

    @ViewBuilder
    func card(_ type: CardType) -> some View {
        switch type {
        case let .content(dateCard):
            Rectangle()
                .foregroundStyle(.red)
        case let .placeholder(index):
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(index <= 1 ? Color.gray200 : Color.gray50)
        }
    }
}

// MARK: DetailView

private extension CalendarDetailView {
    var backgroundView: some View {
        Color.white
            .overlay {
                VStack {
                    LinearGradient(
                        colors: [
                            .black.opacity(0.05),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30)
                    Spacer()
                }
            }
            .ignoresSafeArea(.container, edges: [.bottom])
    }

    var bottomButtonContainer: some View {
        VStack(spacing: .zero) {
            Spacer()
            HStack(spacing: 8) {
                Button {
                    // TODO: 액션
                } label: {
                    Text("이미지 저장")
                }
                .buttonStyle(.master(.large))

                Button {
                    // TODO: 액션
                } label: {
                    Text("이미지 공유")
                }
                .buttonStyle(.master(.large))
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    CalendarDetailView()
}
