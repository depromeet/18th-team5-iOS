//
//  FlowLayout.swift
//  DesignSystem
//
//  Created by 이정원 on 6/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct FlowLayout: Layout {
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat

    public init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = rows(in: proposal.width ?? .infinity, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.map(\.height).reduce(0, +) + verticalSpacing * CGFloat(max(rows.count - 1, 0))
        return .init(width: width, height: height)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = rows(in: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: .init(x: x, y: y),
                    anchor: .topLeading,
                    proposal: .init(size)
                )
                x += size.width + horizontalSpacing
            }

            y += row.height + verticalSpacing
        }
    }
}

private extension FlowLayout {
    struct Row {
        var indices: [Int]
        var width: CGFloat
        var height: CGFloat
    }

    func rows(in maxWidth: CGFloat, subviews: LayoutSubviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row(indices: [], width: 0, height: 0)

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextWidth = if currentRow.indices.isEmpty { size.width } else { currentRow.width + horizontalSpacing + size.width }

            if nextWidth > maxWidth, !currentRow.indices.isEmpty {
                rows.append(currentRow)
                currentRow = Row(indices: [index], width: size.width, height: size.height)
            } else {
                currentRow.indices.append(index)
                currentRow.width = nextWidth
                currentRow.height = max(currentRow.height, size.height)
            }
        }

        if !currentRow.indices.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }
}
