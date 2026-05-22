//
//  CircularWheelPicker.swift
//  DesignSystem
//
//  Created by 이정원 on 4/27/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct CircularWheelPicker<Item: Hashable, Content: View>: View {
    @State private var scrollID: Item?
    @State private var hasScrolledAwayFromTop = false
    @State private var isUserInteractionDisabled = false
    @State private var interactionLockID = 0
    @Binding private var selection: Item

    private let items: [Item]
    private let content: (Item) -> Content
    private let scrollIntensity: CGFloat = 0.5 // (0<..<1)
    private let scrollAnimation: Animation = .easeInOut(duration: 0.4)
    private let interactionLockDuration: Duration = .milliseconds(450)
    private let topOffsetThreshold: CGFloat = 5.0

    public init(
        items: [Item],
        selection: Binding<Item>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self._selection = selection
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            scrollView(proxy: proxy)
        }
    }
}

private extension CircularWheelPicker {
    func scrollView(proxy: GeometryProxy) -> some View {
        let height = proxy.size.height

        return ScrollView(.vertical, showsIndicators: false) {
            scrollContent(proxy: proxy)
        }
        .scrollOffsetCoordinateSpace()
        .allowsHitTesting(!isUserInteractionDisabled)
        .safeAreaPadding(.vertical, safeAreaPadding(for: height))
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $scrollID, anchor: .center)
        .sensoryFeedback(
            .impact(weight: .heavy),
            trigger: scrollID
        ) { old, _ in
            old != nil
        }
        .task { await setInitialScrollPosition() }
        .onChange(of: scrollID) { _, newValue in
            updateSelection(to: newValue)
        }
        .onChange(of: selection) { _, newValue in
            scrollToSelectionIfNeeded(newValue)
        }
    }

    func scrollContent(proxy: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            scrollOffsetMarker
                .readScrollOffset { handleScrollOffset($0) }

            VStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    itemView(item, proxy: proxy)
                }
            }
            .scrollTargetLayout()
        }
    }

    func itemView(_ item: Item, proxy: GeometryProxy) -> some View {
        content(item)
            .frame(
                width: proxy.size.width,
                height: itemHeight(for: proxy.size.height)
            )
            .visualEffect { content, itemProxy in
                let transform = WheelTransform(
                    itemFrame: itemProxy.frame(in: .global),
                    containerFrame: proxy.frame(in: .global),
                    scrollIntensity: scrollIntensity
                )

                return content
                    .rotationEffect(.radians(-transform.angle))
                    .offset(x: transform.offset.width, y: transform.offset.height)
                    .opacity(transform.isVisible ? 1.0 : 0.0)
            }
    }

    var scrollOffsetMarker: some View {
        Color.clear
            .frame(height: 1)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    func itemHeight(for containerHeight: CGFloat) -> CGFloat {
        containerHeight * scrollIntensity
    }

    func safeAreaPadding(for containerHeight: CGFloat) -> CGFloat {
        containerHeight * (1 - scrollIntensity) / 2
    }

    func setInitialScrollPosition() async {
        try? await Task.sleep(for: .milliseconds(50))
        scrollID = selection
    }

    func updateSelection(to item: Item?) {
        guard let item else { return }
        selection = item
    }

    func scrollToSelectionIfNeeded(_ item: Item) {
        guard scrollID != item else { return }
        scrollTo(item)
    }

    func handleScrollOffset(_ offset: CGPoint) {
        guard offset.y < topOffsetThreshold else {
            hasScrolledAwayFromTop = true
            return
        }

        guard hasScrolledAwayFromTop,
              let firstItem = items.first,
              selection != firstItem else {
            return
        }

        selection = firstItem
    }

    func scrollTo(_ item: Item) {
        interactionLockID += 1
        let lockID = interactionLockID
        isUserInteractionDisabled = true

        withAnimation(scrollAnimation) {
            scrollID = item
        }

        Task {
            try? await Task.sleep(for: interactionLockDuration)

            await MainActor.run {
                guard interactionLockID == lockID else { return }
                isUserInteractionDisabled = false
            }
        }
    }
}

private struct WheelTransform {
    let angle: Double
    let offset: CGSize

    init(
        itemFrame: CGRect,
        containerFrame: CGRect,
        scrollIntensity: CGFloat
    ) {
        let scrollCenterY = containerFrame.midY
        let itemCenterY = itemFrame.midY

        let distance = itemCenterY - scrollCenterY
        let angle = -(Double.pi / 6) * distance / (containerFrame.height * scrollIntensity)

        let radius = UIScreen.width
        let pivotX = containerFrame.minX - (radius / 2)
        let pivotY = scrollCenterY

        let targetX = pivotX + radius * cos(angle)
        let targetY = pivotY - radius * sin(angle)

        let currentX = itemFrame.midX
        let currentY = itemFrame.midY

        self.angle = angle
        self.offset = .init(
            width: targetX - currentX,
            height: targetY - currentY
        )
    }

    var isVisible: Bool {
        abs(angle) <= Double.pi / 2
    }
}
