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
    @State private var interactionTask: Task<Void, Never>?
    @Binding private var selection: Item

    private let items: [Item]
    private let content: (Item) -> Content
    private let configuration: CircularWheelPickerConfiguration
    private let scrollIntensity: CGFloat = 0.5 // (0<..<1)
    private let scrollAnimation: Animation = .easeInOut(duration: 0.4)
    private let interactionLockDuration: Duration = .milliseconds(450)
    private let topOffsetThreshold: CGFloat = 5.0

    public init(
        items: [Item],
        selection: Binding<Item>,
        configuration: CircularWheelPickerConfiguration = .missionCard,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self._selection = selection
        self.configuration = configuration
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
        .onDisappear {
            interactionTask?.cancel()
            interactionTask = nil
            isUserInteractionDisabled = false
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
        let geometry = WheelGeometry(
            containerWidth: proxy.size.width,
            configuration: configuration
        )

        return content(item)
            .padding(.leading, configuration.contentLeadingInset)
            .padding(.trailing, configuration.contentTrailingInset)
            .frame(
                width: proxy.size.width,
                height: itemHeight(for: proxy.size.height)
            )
            .visualEffect { content, itemProxy in
                let transform = WheelTransform(
                    itemFrame: itemProxy.frame(in: .global),
                    containerFrame: proxy.frame(in: .global),
                    geometry: geometry,
                    scrollIntensity: scrollIntensity
                )

                return content
                    .rotationEffect(.radians(-transform.angle), anchor: transform.anchor)
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
        guard !isUserInteractionDisabled else { return }

        guard offset.y < topOffsetThreshold else {
            hasScrolledAwayFromTop = true
            return
        }

        guard hasScrolledAwayFromTop else { return }
        hasScrolledAwayFromTop = false

        guard let firstItem = items.first,
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

        interactionTask?.cancel()
        interactionTask = Task {
            try? await Task.sleep(for: interactionLockDuration)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard interactionLockID == lockID else { return }
                isUserInteractionDisabled = false
                interactionTask = nil
            }
        }
    }
}

private struct WheelGeometry {
    let rotationFrameLength: CGFloat
    let contentTrailingInset: CGFloat
    let contentHeight: CGFloat
    let angleStep: Double

    var leadingCornerDistance: CGFloat {
        contentHeight / (2 * CGFloat(tan(angleStep / 2)))
    }

    init(
        containerWidth: CGFloat,
        configuration: CircularWheelPickerConfiguration
    ) {
        let availableWidth = containerWidth - configuration.contentTrailingInset
        self.rotationFrameLength = availableWidth * configuration.rotationFrameLengthRatio
        self.contentTrailingInset = configuration.contentTrailingInset
        self.contentHeight = configuration.contentHeight
        self.angleStep = configuration.angleStep.radians
    }
}

private struct WheelTransform {
    let angle: Double
    let anchor: UnitPoint
    let offset: CGSize

    init(
        itemFrame: CGRect,
        containerFrame: CGRect,
        geometry: WheelGeometry,
        scrollIntensity: CGFloat
    ) {
        let scrollCenterY = containerFrame.midY
        let itemCenterY = itemFrame.midY
        let rotationFrameHalfLength = geometry.rotationFrameLength / 2
        let rotationFrameTrailingX = containerFrame.maxX - geometry.contentTrailingInset
        let rotationCenterX = rotationFrameTrailingX - rotationFrameHalfLength
        let rotationCenterY = itemCenterY

        let distance = itemCenterY - scrollCenterY
        let angle = -geometry.angleStep * distance / (containerFrame.height * scrollIntensity)

        let radius = rotationFrameHalfLength + geometry.leadingCornerDistance
        let pivotX = rotationCenterX - radius
        let pivotY = scrollCenterY

        let targetX = pivotX + radius * cos(angle)
        let targetY = pivotY - radius * sin(angle)

        self.angle = angle
        self.anchor = .init(
            x: (rotationCenterX - itemFrame.minX) / itemFrame.width,
            y: 0.5
        )

        self.offset = .init(
            width: targetX - rotationCenterX,
            height: targetY - rotationCenterY
        )
    }

    var isVisible: Bool {
        abs(angle) <= Double.pi / 2
    }
}
