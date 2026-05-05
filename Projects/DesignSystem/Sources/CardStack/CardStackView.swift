//
//  CardStackView.swift
//  DesignSystem
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct CardStackView<Item: Identifiable, CardView: View>: View {
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    private let items: [Item]
    private let cardWidth: CGFloat
    private let cardHeight: CGFloat
    private let cardView: (Item) -> CardView

    public init(
        items: [Item],
        cardWidth: CGFloat = 200,
        cardHeight: CGFloat = 300,
        cardView: @escaping (Item) -> CardView
    ) {
        self.items = items
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        self.cardView = cardView
    }

    public var body: some View {
        VStack(spacing: 0) {
            cardStack
            navigationButtons
                .padding(.top, 24)
        }
    }
}

private extension CardStackView {
    var cardStack: some View {
        ZStack {
            ForEach(renderEntries, id: \.index) { entry in
                cardView(items[entry.index])
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: CardStackConstants.cornerRadius))
                    .offset(x: offsetForEntry(entry))
                    .scaleEffect(scaleForEntry(entry))
                    .zIndex(zIndexForEntry(entry))
                    .gesture(dragGesture)
            }
        }
        .frame(height: cardHeight)
        .clipped()
    }

    var navigationButtons: some View {
        HStack(spacing: CardStackConstants.buttonSpacing) {
            Button { movePrevious() } label: {
                Image(systemName: "chevron.left")
                    .frame(width: CardStackConstants.buttonSize, height: CardStackConstants.buttonSize)
                    .foregroundStyle(Color.white)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .disabled(currentIndex == 0)

            Button { moveNext() } label: {
                Image(systemName: "chevron.right")
                    .frame(width: CardStackConstants.buttonSize, height: CardStackConstants.buttonSize)
                    .foregroundStyle(Color.white)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .disabled(currentIndex >= items.count - 1)
        }
    }

    var renderEntries: [RenderEntry] {
        let startIndex = max(currentIndex - CardStackConstants.peekBehind, 0)
        let endIndex = min(currentIndex + CardStackConstants.peekAhead, items.count - 1)
        return (startIndex ... endIndex).map { RenderEntry(index: $0) }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let threshold = cardWidth * CardStackConstants.swipeThreshold
                if value.translation.width < -threshold {
                    moveNext()
                } else if value.translation.width > threshold {
                    movePrevious()
                }
                withAnimation(.easeOut) {
                    dragOffset = 0
                }
            }
    }
}

private enum CardStackConstants {
    static let cornerRadius: CGFloat = 16
    static let buttonSize: CGFloat = 44
    static let buttonSpacing: CGFloat = 40
    static let peekAhead: Int = 2
    static let peekBehind: Int = 1
    static let swipeThreshold: CGFloat = 0.3
    static let cardOffsetFactor: CGFloat = 30
    static let cardScaleDecay: CGFloat = 0.05
}

private extension CardStackView {
    struct RenderEntry {
        let index: Int
    }
}

private extension CardStackView {
    func offsetForEntry(_ entry: RenderEntry) -> CGFloat {
        let baseOffset = CGFloat(entry.index - currentIndex) * CardStackConstants.cardOffsetFactor
        let dragContribution = CGFloat(entry.index - currentIndex) * dragOffset / cardWidth
        return baseOffset + dragContribution
    }

    func scaleForEntry(_ entry: RenderEntry) -> CGFloat {
        let distance = abs(entry.index - currentIndex)
        return 1.0 - CGFloat(distance) * CardStackConstants.cardScaleDecay
    }

    func zIndexForEntry(_ entry: RenderEntry) -> Double {
        Double(CardStackConstants.peekAhead + CardStackConstants.peekBehind) - Double(abs(entry.index - currentIndex))
    }

    func moveNext() {
        guard currentIndex < items.count - 1 else { return }
        withAnimation(.easeInOut) {
            currentIndex += 1
            dragOffset = 0
        }
    }

    func movePrevious() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut) {
            currentIndex -= 1
            dragOffset = 0
        }
    }
}
