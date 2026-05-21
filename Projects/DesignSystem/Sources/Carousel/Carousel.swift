//
//  Carousel.swift
//  DesignSystem
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct Carousel<Item: Hashable, Content: View>: View {
    private let items: [Item]
    private let spacing: CGFloat
    private let aspectRatio: CGFloat
    private let edgeRatio: CGFloat
    private let shrinkRatio: CGFloat
    private let scrollPosition: Binding<Item?>?
    private let content: (Item) -> Content

    public init(
        items: [Item],
        spacing: CGFloat,
        aspectRatio: CGFloat,
        edgeRatio: CGFloat = 0.2,
        shrinkRatio: CGFloat = 0.9,
        scrollPosition: Binding<Item?>? = nil,
        content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self.aspectRatio = aspectRatio
        self.edgeRatio = min(max(edgeRatio, 0.0), 1.0)
        self.shrinkRatio = min(max(shrinkRatio, 0.5), 1.0)
        self.scrollPosition = scrollPosition
        self.content = content
    }

    public var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: adjustedSpacing) {
                ForEach(items, id: \.self) { item in
                    content(item)
                        .frame(width: itemWidth, height: itemHeight)
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : shrinkRatio)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .safeAreaPadding(.horizontal, padding)
        .frame(height: itemHeight)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: scrollPosition ?? .constant(nil))
    }
}

private extension Carousel {
    var itemWidth: CGFloat {
        max((UIScreen.width - 2 * spacing) / (1 + 2 * shrinkRatio * edgeRatio), 0)
    }

    var adjustedSpacing: CGFloat {
        spacing - itemWidth * (1 - shrinkRatio) / 2
    }

    var itemHeight: CGFloat {
        max(itemWidth / aspectRatio, 0)
    }

    var padding: CGFloat {
        spacing + edgeWidth
    }

    var edgeWidth: CGFloat {
        itemWidth * shrinkRatio * edgeRatio
    }
}
