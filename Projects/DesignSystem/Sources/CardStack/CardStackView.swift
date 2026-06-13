//
//  CardStackView.swift
//  DesignSystem
//
//  Created by NHN on 6/2/26.
//

import Core
import SwiftUI

enum Constants {
    static let maxDisplayCardCount: Int = 3
    static let dragToDismissThresholdPercent: CGFloat = 0.35
    static let dragVelocityThreshold: CGFloat = 25
    static let cardOffsetYGap: CGFloat = 18
    static let stackMinScale: CGFloat = 0.75
}

public struct CardStackView<Item, CardView: View>: View {
    private let items: [Item]
    private let originalCardCount: Int

    @Binding private var outerTopCardItemIndex: Int
    @State private var innerTopCardItemIndex: Int
    @State private var prevDragOffset: CGPoint?
    @State private var dragPercent: CGFloat = 0
    @State private var cardOffsets: [Int: CGFloat] = [:]
    @State private var cardOpacities: [Int: CGFloat] = [:]
    @State private var dismissingCardItemIndices: Set<Int> = []

    // Draging card state
    @State private var currentDragableCardOffsetY: CGFloat = 0
    @State private var currentDragableCardOpacity: CGFloat = 1.0

    // Card UI
    @State private var cardSize: CGSize = .zero
    private var cardView: (Int, Int, Item) -> CardView

    public init(
        topCardIndex: Binding<Int>,
        items: [Item],
        @ViewBuilder cardView: @escaping (Int, Int, Item) -> CardView
    ) {
        self._outerTopCardItemIndex = topCardIndex
        self.innerTopCardItemIndex = topCardIndex.wrappedValue
        self.originalCardCount = items.count
        self.items = {
            guard !items.isEmpty else { return [] }
            var populatedItems: [Item] = items
            while populatedItems.count <= Constants.maxDisplayCardCount * 2 {
                populatedItems.append(contentsOf: items)
            }
            return populatedItems
        }()
        self.cardView = cardView
    }

    public var body: some View {
        ZStack {
            ForEach(renderedEntries, id: \.itemIndex) { entry in
                let scale = scale(for: entry)
                let cardIndex = (entry.itemIndex % originalCardCount)
                cardView(cardIndex, entry.olderIndex, entry.item)
                    .onGeometryChange(
                        for: CGSize.self,
                        of: { $0.size }
                    ) { cardSize = $0 }
                    .scaleEffect(x: scale, y: scale, anchor: .top)
                    .offset(x: 0, y: offsetY(for: entry))
                    .opacity(opacity(for: entry))
            }
        }
        .gesture(dragGesture)
        .padding(.top, stackTopPadding)
        .onChange(of: innerTopCardItemIndex) { _, newValue in
            outerTopCardItemIndex = (newValue % originalCardCount)
        }
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
        let renderCount = min(Constants.maxDisplayCardCount, items.count)
        var indices: [Int] = []
        var index = startIndex
        while indices.count < renderCount {
            indices.append(index)
            index = (index + 1) % endIndex
        }
        return indices
    }

    var renderedEntries: [RenderEntry] {
        let idleCardStack: [RenderEntry] = itemIndices(
            startIndex: innerTopCardItemIndex,
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
        // #1. 사라지는 중인 카드 여부
        if entry.isDismissing {
            return cardOffsets[entry.itemIndex] ?? 0
        }

        // #2. 현재 드래그 가능한 카드인지 확인
        let isTopCard = (entry.itemIndex == innerTopCardItemIndex)
        if isTopCard {
            return currentDragableCardOffsetY
        }

        // #3. 일반 카드
        let chunk = Constants.cardOffsetYGap
        return chunk * (dragPercent - CGFloat(entry.olderIndex))
    }

    func opacity(for entry: RenderEntry) -> CGFloat {
        // #1. 사라지는 중인 카드 여부
        if entry.isDismissing {
            return cardOpacities[entry.itemIndex] ?? 0
        }

        // #2. 현재 드래그 가능한 카드인지 확인
        let isTopCard = (entry.itemIndex == innerTopCardItemIndex)
        if isTopCard {
            return currentDragableCardOpacity
        }

        // #3. 일반 카드
        return 1.0
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
        Constants.cardOffsetYGap * CGFloat(max(0, Constants.maxDisplayCardCount - 1))
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

                // 드래그 카드 오프셋
                currentDragableCardOffsetY += (dY * 0.65)

                // 드래그 퍼센트(0~1)
                dragPercent = max(0, min(1, abs(state.translation.height) * 0.25 / dragThreshold))

                // 드래그 카드 투명도
                currentDragableCardOpacity = 1 - dragPercent
            }
            .onEnded { state in
                let dragDirection = DragDirection(
                    translation: state.translation.height,
                    velocity: state.velocity.height,
                    threshold: dragThreshold
                )
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

        init(translation: CGFloat, velocity: CGFloat, threshold: CGFloat) {
            // 드래그 이동량이 일정양 넘어설때만 비교 기준으로 사용
            let reference = abs(translation) >= threshold ? translation : velocity
            self = reference > 0 ? .bottom : .top
        }
    }
}

// MARK: - Snap Actions

private extension CardStackView {
    func snapToIdentity() {
        prevDragOffset = nil
        withAnimation {
            currentDragableCardOpacity = 1.0
            currentDragableCardOffsetY = .zero
            dragPercent = 0
        }
    }

    func snapToDismiss(direction: DragDirection, verticalVelocity: CGFloat) {
        prevDragOffset = nil

        let dismissIdx = innerTopCardItemIndex
        let startOffsetY = currentDragableCardOffsetY
        let startOpacity = currentDragableCardOpacity

        cardOffsets[dismissIdx] = startOffsetY
        cardOpacities[dismissIdx] = startOpacity

        dismissingCardItemIndices.insert(dismissIdx)
        currentDragableCardOffsetY = 0
        currentDragableCardOpacity = 1.0

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
            innerTopCardItemIndex = (innerTopCardItemIndex + 1) % items.endIndex
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

struct CardModel: Hashable {
    let color: Color = .random()
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
    ) { _, _, item in
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(item.color)
        }
        .frame(width: 200, height: 300)
    }
    .border(.red)
}

#Preview("원카드") {
    @Previewable @State var topCardIndex = 0

    CardStackView(
        topCardIndex: $topCardIndex,
        items: [CardModel()]
    ) { _, _, item in
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(item.color)
        }
        .frame(width: 200, height: 300)
    }
    .border(.red)
}
