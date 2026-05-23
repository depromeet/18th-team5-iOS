//
//  CardStackView.swift
//  DesignSystem
//
//  Created by choijunios on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Core
import SwiftUI

private enum Constants {
    static let maxDisplayCardCount: Int = 5
    static let dragToDismissThresholdPercent: CGFloat = 0.5
    static let dismissTargetY: CGFloat = 700
    static let cardOffsetYGap: CGFloat = 23
    static let stackMinScale: CGFloat = 0.75
}

public struct CardStackView<Item, CardView: View>: View {
    @Binding var topCardIndex: Int
    private let items: [Item]
    @State private var currentDragableCardOffsetY: CGFloat = 0
    @State private var prevDragOffset: CGPoint?
    @State private var dragPercent: CGFloat = 0
    @State private var cardOffsets: [Int: CGFloat] = [:]
    @State private var dismissingIndices: [Int] = []
    @State private var cardSize: CGSize?

    private var cardView: (Int, Item) -> CardView

    public init(
        topCardIndex: Binding<Int>,
        items: [Item],
        cardView: @escaping (Int, Item) -> CardView
    ) {
        self._topCardIndex = topCardIndex
        self.items = items
        self.cardView = cardView
    }

    public var body: some View {
        ZStack {
            ForEach(renderedEntries, id: \.realIndex) { entry in
                cardView(entry.realIndex, entry.item)
                    .size { cardSize = $0 }
                    .offset(x: 0, y: offsetY(for: entry))
                    .scaleEffect(scale(for: entry))
            }
        }
        .gesture(dragGesture)
        .padding(.top, stackTopPadding)
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
            if !dismissingIndices.contains(index) {
                stack.append(RenderEntry(
                    item: item,
                    realIndex: index,
                    relativePosition: index - topCardIndex,
                    isDismissing: false
                ))
            }
        }
        let stackInDrawOrder = Array(stack.reversed())

        let dismissing: [RenderEntry] = dismissingIndices.compactMap { index in
            guard let item = items[safe: index] else { return nil }
            return RenderEntry(
                item: item,
                realIndex: index,
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
        if entry.isDismissing { return cardOffsets[entry.realIndex] ?? 0 }
        if entry.realIndex == topCardIndex { return currentDragableCardOffsetY }
        let chunk = Constants.cardOffsetYGap
        return chunk * (dragPercent - CGFloat(entry.relativePosition))
    }

    private func scale(for entry: RenderEntry) -> CGFloat {
        if entry.isDismissing { return 1.0 }
        let scaleRange = 1.0 - Constants.stackMinScale
        let chunk = scaleRange / CGFloat(Constants.maxDisplayCardCount)
        return 1.0 - chunk * (CGFloat(entry.relativePosition) - dragPercent)
    }

    /// 마지막 카드의 idle 상태 visual top Y값을 기준으로 필요한 top padding을 계산합니다.
    /// scaleEffect는 카드 중심을 기준으로 축소되므로, 위쪽 엣지가 중심 방향으로 당겨집니다.
    private var stackTopPadding: CGFloat {
        let rearPos = Constants.maxDisplayCardCount - 1
        let rearOffsetY = -Constants.cardOffsetYGap * CGFloat(rearPos)

        let scaleRange = 1.0 - Constants.stackMinScale
        let scaleChunk = scaleRange / CGFloat(Constants.maxDisplayCardCount)
        let rearScale = 1.0 - scaleChunk * CGFloat(rearPos)

        let cardHeight = cardSize?.height ?? 0
        let scaleCompensation = cardHeight / 2 * (1 - rearScale)

        return max(0, abs(rearOffsetY) - scaleCompensation)
    }
}

// MARK: - Drag Gesture

extension CardStackView {
    private var dragThreshold: CGFloat {
        (cardSize?.height ?? 300) * Constants.dragToDismissThresholdPercent
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

        let dismissingIndex = topCardIndex
        let startOffsetY = currentDragableCardOffsetY

        cardOffsets[dismissingIndex] = startOffsetY
        dismissingIndices.append(dismissingIndex)
        currentDragableCardOffsetY = 0

        let remainingDistance = Constants.dismissTargetY - startOffsetY
        let initialVelocity: CGFloat = remainingDistance > 0
            ? max(0, verticalVelocity / remainingDistance)
            : 0

        withAnimation(.easeInOut) {
            dragPercent = 0
            topCardIndex += 1
        }

        withAnimation(.interpolatingSpring(stiffness: 120, damping: 18, initialVelocity: initialVelocity)) {
            cardOffsets[dismissingIndex] = Constants.dismissTargetY
        } completion: {
            dismissingIndices.removeAll { $0 == dismissingIndex }
            cardOffsets[dismissingIndex] = nil
        }
    }
}

// TODO: 삭제예정 - @준영

public struct CardModel: Hashable {
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

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private extension View {
    func size(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { size in
            onChange(size)
        }
    }
}

#Preview {
    @Previewable @State var topCardIndex = 0

    CardStackView(
        topCardIndex: $topCardIndex,
        items: (0 ..< 10).map { _ in CardModel() }
    ) { _, item in
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(item.color)
        }
        .frame(width: 200, height: 300)
    }
    .border(.red)
}
