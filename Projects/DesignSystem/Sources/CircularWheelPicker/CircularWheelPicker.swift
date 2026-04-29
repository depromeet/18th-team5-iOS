//
//  CircularWheelPicker.swift
//  DesignSystem
//
//  Created by 이정원 on 4/27/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct CircularWheelPicker<Item: Hashable, Content: View>: View {
    private let items: [Item]
    @Binding private var selection: Item
    private let content: (Item) -> Content
    @State private var scrollID: Item?
    private let scrollIntensity: CGFloat = 0.5 // (0<..<1)

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
            let width = proxy.size.width
            let height = proxy.size.height

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .frame(width: width, height: height * scrollIntensity)
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
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.vertical, height * (1 - scrollIntensity) / 2)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $scrollID, anchor: .center)
            .sensoryFeedback(.impact(weight: .heavy), trigger: scrollID) { old, _ in
                old != nil
            }
            .task {
                try? await Task.sleep(for: .milliseconds(50))
                scrollID = selection
            }
            .onChange(of: scrollID) { _, newValue in
                if let newValue { selection = newValue }
            }
            .onChange(of: selection) { _, newValue in
                scrollID = newValue
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
