//
//  CardStackView.swift
//  DesignSystem
//
//  Created by choijunios on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

private enum Constants {
    // MARK: 카드 크기 수정예정 - @준영

    static let cardWidth: CGFloat = 200
    static let cardHeight: CGFloat = 300

    static let maxDisplayCardCount: Int = 5
    static let dragToDismissThresholdPercent: CGFloat = 0.5
    static let dismissTargetY: CGFloat = 700
    static let stackOffsetSpan: CGFloat = 100
    static let stackMinScale: CGFloat = 0.75
}

public struct CardStackView<Item: Identifiable, CardView: View>: View {
    @Binding var topCardIndex: Int
    @State private var items: [Item]
    @State private var currentDragableCardOffsetY: CGFloat = 0
    @State private var prevDragOffset: CGPoint?
    @State private var dragPercent: CGFloat = 0
    @State private var cardOffsets: [Item.ID: CGFloat] = [:]
    @State private var dismissingIds: [Item.ID] = []

    private var cardView: (Item) -> CardView

    public init(
        topCardIndex: Binding<Int>,
        items: [Item],
        cardView: @escaping (Item) -> CardView
    ) {
        self._topCardIndex = topCardIndex
        self.items = items
        self.cardView = cardView

        guard !items.isEmpty else { return }
    }

    public var body: some View {
        ZStack {
            ForEach(renderedEntries, id: \.item.id) { entry in
                cardView(entry.item)
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                    .offset(x: 0, y: offsetY(for: entry))
                    .scaleEffect(scale(for: entry))
            }
        }
        .gesture(dragGesture)
    }
}

// MARK: - Render Entry

extension CardStackView {
    private struct RenderEntry {
        let item: Item
        let realIndex: Int
        let relativePosition: Int
        let isDismissing: Bool
    }

    private var renderedEntries: [RenderEntry] {
        var stack: [RenderEntry] = []
        let endIndex = min(topCardIndex + Constants.maxDisplayCardCount, items.endIndex)
        for index in topCardIndex ..< endIndex {
            let item = items[index]
            if !dismissingIds.contains(item.id) {
                stack.append(RenderEntry(
                    item: item,
                    realIndex: index,
                    relativePosition: index - topCardIndex,
                    isDismissing: false
                ))
            }
        }
        let stackInDrawOrder = Array(stack.reversed())

        let dismissing: [RenderEntry] = dismissingIds.compactMap { id in
            guard let itemIndex = items.firstIndex(where: { $0.id == id })
            else { return nil }
            return RenderEntry(
                item: items[itemIndex],
                realIndex: itemIndex,
                relativePosition: 0,
                isDismissing: true
            )
        }
        return stackInDrawOrder + dismissing
    }
}

// MARK: - Card Transform

extension CardStackView {
    private func offsetY(for entry: RenderEntry) -> CGFloat {
        if entry.isDismissing { return cardOffsets[entry.item.id] ?? 0 }
        if entry.realIndex == topCardIndex { return currentDragableCardOffsetY }
        let chunk = Constants.stackOffsetSpan / CGFloat(Constants.maxDisplayCardCount)
        return chunk * (dragPercent - CGFloat(entry.relativePosition))
    }

    private func scale(for entry: RenderEntry) -> CGFloat {
        if entry.isDismissing { return 1.0 }
        let scaleRange = 1.0 - Constants.stackMinScale
        let chunk = scaleRange / CGFloat(Constants.maxDisplayCardCount)
        return 1.0 - chunk * (CGFloat(entry.relativePosition) - dragPercent)
    }
}

// MARK: - Drag Gesture

extension CardStackView {
    private var dragThreshold: CGFloat {
        Constants.cardHeight * Constants.dragToDismissThresholdPercent
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { state in
                if prevDragOffset == nil {
                    prevDragOffset = state.startLocation
                }
                guard let prev = prevDragOffset else { return }
                let dY = state.location.y - prev.y
                prevDragOffset = state.location

                currentDragableCardOffsetY += dY
                dragPercent = max(0, min(1, state.translation.height / dragThreshold)) * 0.5
            }
            .onEnded { state in
                if state.translation.height >= dragThreshold {
                    snapToDismiss(verticalVelocity: state.velocity.height)
                } else {
                    snapToIdentity()
                }
            }
    }
}

// MARK: - Snap Actions

extension CardStackView {
    private func snapToIdentity() {
        prevDragOffset = nil
        withAnimation {
            currentDragableCardOffsetY = .zero
            dragPercent = 0
        }
    }

    private func snapToDismiss(verticalVelocity: CGFloat) {
        if topCardIndex == items.endIndex - 1 {
            snapToIdentity()
            return
        }

        prevDragOffset = nil

        let dismissingId = items[topCardIndex].id
        let startOffsetY = currentDragableCardOffsetY

        cardOffsets[dismissingId] = startOffsetY
        dismissingIds.append(dismissingId)
        currentDragableCardOffsetY = 0

        let remainingDistance = Constants.dismissTargetY - startOffsetY
        let initialVelocity: CGFloat = remainingDistance > 0
            ? max(0, verticalVelocity / remainingDistance)
            : 0

        withAnimation {
            dragPercent = 0
            topCardIndex += 1
        }

        withAnimation(.interpolatingSpring(stiffness: 120, damping: 18, initialVelocity: initialVelocity)) {
            cardOffsets[dismissingId] = Constants.dismissTargetY
        } completion: {
            dismissingIds.removeAll { $0 == dismissingId }
            cardOffsets[dismissingId] = nil
        }
    }
}

// TODO: 삭제예정 - @준영

public struct CardModel: Identifiable, Hashable {
    public let id = UUID()
    public let color: Color = .random()

    public init() {}
}

// TODO: 삭제예정 - @준영

extension Color {
    static func random() -> Color {
        Color(
            red: Double.random(in: 0 ... 1),
            green: Double.random(in: 0 ... 1),
            blue: Double.random(in: 0 ... 1)
        )
    }
}

// TODO: 삭제예정 - @준영

struct CardView: View {
    var item: CardModel
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(item.color)
            Text(item.id.uuidString)
                .font(.body)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    @Previewable @State var topCardIndex = 0

    CardStackView(
        topCardIndex: $topCardIndex,
        items: (0 ..< 10).map { _ in CardModel() }
    ) { CardView(item: $0) }
}
