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
    // 화면에 노출되는 카드중 가장 상단에 위치한 카드 인덱스입니다.
    @Binding var displayPointer: Int

    // 배열의 앞쪽에 위치할 수록 먼저 노출됩니다.
    @State private var items: [Item]

    @State private var dragableCardId: Item.ID?
    @State private var currentDragableCardOffsetY: CGFloat = 0
    @State private var prevDragOffset: CGPoint?

    // 드래그 임계값 대비 진행도(0~1) — 스택 카드의 stair-step 보간에 사용.
    @State private var dragPercent: CGFloat = 0

    // 사라지는 카드는 별도 뷰가 아니라 같은 ForEach 안에서 자기만의 offset을
    // 들고 슬라이드합니다. 드래그 → dismiss 순간에 뷰 정체성이 끊기지 않습니다.
    @State private var cardOffsets: [Item.ID: CGFloat] = [:]
    @State private var dismissingIds: [Item.ID] = []

    private var cardView: (Item) -> CardView

    public init(
        topCardIndex: Binding<Int>,
        items: [Item],
        cardView: @escaping (Item) -> CardView
    ) {
        self._displayPointer = topCardIndex
        self.items = items
        self.cardView = cardView

        guard !items.isEmpty else { return }
        self._dragableCardId = State(initialValue: items.first!.id)
    }

    public var body: some View {
        ZStack {
            Color.clear
            ForEach(renderedEntries, id: \.item.id) { entry in
                cardView(entry.item)
                    .frame(width: Constants.cardWidth, height: Constants.cardHeight)
                    .offset(x: 0, y: offsetY(for: entry))
                    .scaleEffect(scale(for: entry))
            }
            navigationButtons
        }
        .gesture(dragGesture)
    }

    private struct RenderEntry {
        let item: Item
        let relativePosition: Int
        let isDismissing: Bool
    }

    // 스택 카드 + dismiss 진행 중인 카드를 하나의 ForEach에 합쳐서 그립니다.
    // displayPointer가 옮겨가도 dismissingIds로 별도 식별되므로, 사라지는
    // 카드는 stack 범위에서 빠진 뒤에도 화면에 그대로 남아 애니메이션을 마칩니다.
    private var renderedEntries: [RenderEntry] {
        var stack: [RenderEntry] = []
        let endIndex = min(displayPointer + Constants.maxDisplayCardCount, items.endIndex)
        for index in displayPointer ..< endIndex {
            let item = items[index]
            if !dismissingIds.contains(item.id) {
                stack.append(RenderEntry(
                    item: item,
                    relativePosition: index - displayPointer,
                    isDismissing: false
                ))
            }
        }
        // 뒤 카드 → 앞 카드 순으로 그려야 z-order가 맞음
        let stackInDrawOrder = Array(stack.reversed())

        // dismiss 카드는 항상 스택 위에 그림
        let dismissing: [RenderEntry] = dismissingIds.compactMap { id in
            guard let item = items.first(where: { $0.id == id }) else { return nil }
            return RenderEntry(item: item, relativePosition: 0, isDismissing: true)
        }

        return stackInDrawOrder + dismissing
    }

    // 분기 우선순위: dismiss > front > stack.
    // release 직후 dragableCardId가 잠깐 옛 카드를 가리키는 동안에도
    // isDismissing이 먼저 검사되므로 옛 카드는 cardOffsets로 정확히 그려집니다.
    private func offsetY(for entry: RenderEntry) -> CGFloat {
        if entry.isDismissing { return cardOffsets[entry.item.id] ?? 0 }
        if entry.item.id == dragableCardId { return currentDragableCardOffsetY }
        let chunk = Constants.stackOffsetSpan / CGFloat(Constants.maxDisplayCardCount)
        return chunk * (dragPercent - CGFloat(entry.relativePosition))
    }

    private func scale(for entry: RenderEntry) -> CGFloat {
        if entry.isDismissing { return 1.0 }
        let scaleRange = 1.0 - Constants.stackMinScale
        let chunk = scaleRange / CGFloat(Constants.maxDisplayCardCount)
        return 1.0 - chunk * (CGFloat(entry.relativePosition) - dragPercent)
    }

    private var navigationButtons: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Button("다음") {
                        withAnimation {
                            displayPointer += 1
                            dragableCardId = items[displayPointer].id
                        }
                    }
                    .disabled(displayPointer == items.endIndex - 1)

                    Button("이전") {
                        withAnimation {
                            displayPointer -= 1
                            dragableCardId = items[displayPointer].id
                        }
                    }
                    .disabled(displayPointer == 0)
                }
                .padding([.trailing, .bottom], 30)
            }
        }
    }

    private var dragThreshold: CGFloat {
        Constants.cardHeight * Constants.dragToDismissThresholdPercent
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { state in
                if prevDragOffset == nil {
                    prevDragOffset = state.startLocation
                }
                let dY = state.location.y - prevDragOffset!.y
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

    private func snapToIdentity() {
        prevDragOffset = nil
        withAnimation {
            currentDragableCardOffsetY = .zero
            dragPercent = 0
        }
    }

    private func snapToDismiss(verticalVelocity: CGFloat) {
        guard let frontIndex = items.firstIndex(where: { $0.id == dragableCardId })
        else { return }

        if frontIndex == items.endIndex - 1 {
            snapToIdentity()
            return
        }

        prevDragOffset = nil

        let dismissingId = items[frontIndex].id
        let startOffsetY = currentDragableCardOffsetY

        // 현재 드래그 위치를 사라지는 카드에게 이관.
        // dragableCardId는 아직 옛 카드를 가리키지만 isDismissing 분기가 우선이라 안전.
        cardOffsets[dismissingId] = startOffsetY
        dismissingIds.append(dismissingId)
        currentDragableCardOffsetY = 0

        // 손가락 속도(pt/s) ÷ 남은 거리(pt) = interpolatingSpring의 initialVelocity 단위(/s).
        // 예: 1500pt/s로 던졌고 남은 거리가 500pt라면 초기 속도는 3.0/s.
        let remainingDistance = Constants.dismissTargetY - startOffsetY
        let initialVelocity: CGFloat = remainingDistance > 0
            ? max(0, verticalVelocity / remainingDistance)
            : 0

        // 뒤 카드들을 한 단계씩 앞으로 정렬
        withAnimation {
            dragPercent = 0
            displayPointer += 1
            dragableCardId = items[displayPointer].id
        }

        // 사라지는 카드를 화면 밖으로 — 드래그 속도가 spring 초기 속도로 그대로 이어집니다.
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
    CardStackView(
        topCardIndex: .constant(0),
        items: (0 ..< 10).map { _ in CardModel() }
    ) { CardView(item: $0) }
}
