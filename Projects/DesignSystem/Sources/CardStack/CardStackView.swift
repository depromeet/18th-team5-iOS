//
//  CardStackView.swift
//  SUPlayground
//
//  Created by NHN on 6/2/26.
//

import Core
import SwiftUI

enum Constants {
    static let maxDisplayCardCount: Int = 3
    static let dragToDismissThresholdPercent: CGFloat = 0.35
    static let dragVelocityThreshold: CGFloat = 25
    static let cardOffsetYGap: CGFloat = 23
    static let stackMinScale: CGFloat = 0.75
}

public struct CardStackView<Item, CardView: View>: View {
    private let items: [Item]

    @Binding private var topCardItemIndex: Int
    @State private var currentDragableCardOffsetY: CGFloat = 0
    @State private var prevDragOffset: CGPoint?
    @State private var dragPercent: CGFloat = 0
    @State private var cardOffsets: [Int: CGFloat] = [:]
    @State private var cardOpacities: [Int: CGFloat] = [:]
    @State private var dismissingCardItemIndices: Set<Int> = []

    // Card UI
    @State private var cardSize: CGSize = .zero
    private var cardView: (Int, Item) -> CardView

    public init(
        topCardIndex: Binding<Int>,
        items: [Item],
        @ViewBuilder cardView: @escaping (Int, Item) -> CardView
    ) {
        self._topCardItemIndex = topCardIndex
        self.items = items
        self.cardView = cardView
    }

    public var body: some View {
        ZStack {
            ForEach(renderedEntries, id: \.itemIndex) { entry in
                cardView(entry.itemIndex, entry.item)
                    .onGeometryChange(
                        for: CGSize.self,
                        of: { $0.size }
                    ) { cardSize = $0 }
                    .offset(x: 0, y: offsetY(for: entry))
                    .opacity(cardOpacities[entry.itemIndex] ?? 1)
                    .scaleEffect(scale(for: entry))
            }
        }
        .gesture(dragGesture)
        .padding(.top, stackTopPadding)
    }
}

// MARK: - Render Entry

private extension CardStackView {
    struct RenderEntry {
        let item: Item
        let itemIndex: Int
        let olderIndex: Int
        let isDismissing: Bool
    }

    func itemIndices(startIndex: Int, endIndex: Int) -> [Int] {
        guard items.indices.contains(startIndex) else { return [] }
        var indices: [Int] = []
        var index = startIndex
        while indices.count < Constants.maxDisplayCardCount {
            indices.append(index)
            index = (index + 1) % endIndex
        }
        return indices
    }

    var renderedEntries: [RenderEntry] {
        let idleCardStack: [RenderEntry] = itemIndices(
            startIndex: topCardItemIndex,
            endIndex: items.endIndex
        )
        .enumerated()
        .compactMap { orderIndex, itemIndex in
            guard !dismissingCardItemIndices.contains(itemIndex) else { return nil }
            return RenderEntry(
                item: items[itemIndex],
                itemIndex: itemIndex,
                olderIndex: orderIndex,
                isDismissing: false
            )
        }
        var idleCardStack2: [RenderEntry] = []
        var currentIndex = topCardItemIndex
        while idleCardStack2.count < Constants.maxDisplayCardCount {
            if !dismissingCardItemIndices.contains(currentIndex) {
                idleCardStack2.append(
                    RenderEntry(
                        item: items[currentIndex],
                        itemIndex: currentIndex,
                        olderIndex: idleCardStack2.count,
                        isDismissing: false
                    )
                )
            }
            currentIndex = (currentIndex + 1) % items.endIndex
        }

        let dismissingCardStack: [RenderEntry] = dismissingCardItemIndices.compactMap { index in
            guard let item = items[safe: index] else { return nil }
            return RenderEntry(
                item: item,
                itemIndex: index,
                olderIndex: 0,
                isDismissing: true
            )
        }
        return (dismissingCardStack + idleCardStack).reversed()
    }
}

// MARK: - Card Transform

private extension CardStackView {
    func offsetY(for entry: RenderEntry) -> CGFloat {
        if entry.isDismissing { return cardOffsets[entry.itemIndex] ?? 0 }
        if entry.itemIndex == topCardItemIndex {
            return currentDragableCardOffsetY
        }
        let chunk = Constants.cardOffsetYGap
        return chunk * (dragPercent - CGFloat(entry.olderIndex))
    }

    func scale(for entry: RenderEntry) -> CGFloat {
        if entry.isDismissing || entry.olderIndex == 0 {
            return 1.0
        }
        let scaleRange = 1.0 - Constants.stackMinScale
        let chunk = scaleRange / CGFloat(Constants.maxDisplayCardCount)
        return 1.0 - chunk * (CGFloat(entry.olderIndex) - dragPercent)
    }

    /// 마지막 카드의 idle 상태 visual top Y값을 기준으로 필요한 top padding을 계산합니다.
    /// scaleEffect는 카드 중심을 기준으로 축소되므로, 위쪽 엣지가 중심 방향으로 당겨집니다.
    var stackTopPadding: CGFloat {
        let rearPos = Constants.maxDisplayCardCount - 1
        let rearOffsetY = -Constants.cardOffsetYGap * CGFloat(rearPos)

        let scaleRange = 1.0 - Constants.stackMinScale
        let scaleChunk = scaleRange / CGFloat(Constants.maxDisplayCardCount)
        let rearScale = 1.0 - scaleChunk * CGFloat(rearPos)

        let scaleCompensation = cardSize.height / 2 * (1 - rearScale)
        return max(0, abs(rearOffsetY) - scaleCompensation)
    }
}

// MARK: - Drag Gesture

private extension CardStackView {
    var dragThreshold: CGFloat {
        max(cardSize.height, 1) * Constants.dragToDismissThresholdPercent
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { state in
                if prevDragOffset == nil {
                    prevDragOffset = state.startLocation
                }
                guard let prev = prevDragOffset else { return }
                let dY = state.location.y - prev.y
                prevDragOffset = state.location

                currentDragableCardOffsetY += (dY * 0.65)
                dragPercent = max(0, min(1, state.translation.height * 0.25 / dragThreshold))
            }
            .onEnded { state in
                let dragDirection = DragDirection(translation: state.translation.height)
                if abs(state.translation.height) >= dragThreshold ||
                    abs(state.velocity.height) > Constants.dragVelocityThreshold {
                    snapToDismiss(
                        direction: dragDirection,
                        verticalVelocity: state.velocity.height
                    )
                } else {
                    snapToIdentity()
                }
            }
    }

    enum DragDirection {
        case top, bottom

        init(translation: CGFloat) {
            self = translation > 0 ? .bottom : .top
        }
    }
}

// MARK: - Snap Actions

private extension CardStackView {
    func snapToIdentity() {
        prevDragOffset = nil
        withAnimation {
            currentDragableCardOffsetY = .zero
            dragPercent = 0
        }
    }

    func snapToDismiss(direction: DragDirection, verticalVelocity: CGFloat) {
        prevDragOffset = nil

        let dismissIdx = topCardItemIndex
        let startOffsetY = currentDragableCardOffsetY

        cardOffsets[dismissIdx] = startOffsetY
        dismissingCardItemIndices.insert(dismissIdx)
        currentDragableCardOffsetY = 0

        let dismissYPos = switch direction {
        case .top: -cardSize.height
        case .bottom: cardSize.height
        }

        let remainingDistance = dismissYPos - startOffsetY
        let initialVelocity: CGFloat = remainingDistance > 0
            ? max(0, verticalVelocity / remainingDistance)
            : 0

        withAnimation(.easeInOut) {
            dragPercent = 0
            topCardItemIndex = (topCardItemIndex + 1) % items.endIndex
        }

        withAnimation(.interpolatingSpring(stiffness: 120, damping: 18, initialVelocity: initialVelocity)) {
            cardOffsets[dismissIdx] = dismissYPos
            cardOpacities[dismissIdx] = 0.0
        } completion: {
            DispatchQueue.main.async {
                dismissingCardItemIndices.remove(dismissIdx)
                cardOffsets.removeValue(forKey: dismissIdx)
                cardOpacities.removeValue(forKey: dismissIdx)
            }
        }
    }
}

#if Debug

struct CardModel: Hashable {
    let color: Color = .random()

    init() {}
}

extension Color {
    static func random() -> Color {
        Color(
            red: Double.random(in: 0 ... 1),
            green: Double.random(in: 0 ... 1),
            blue: Double.random(in: 0 ... 1)
        )
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
#endif
