//
//  CalendarCellImageShape.swift
//  Presentation
//
//  Created by choijunios on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

struct CalendarCellImageShape: Shape {
    let containerPadding: CGFloat
    let containerRadius: CGFloat
    let protrusionRadius: CGFloat

    func path(in rect: CGRect) -> SwiftUI.Path {
        SwiftUI.Path { path in
            path.addRoundedRect(
                in: CGRect(
                    x: containerPadding,
                    y: containerPadding,
                    width: rect.width - containerPadding * 2,
                    height: rect.height - containerPadding * 2
                ),
                cornerSize: CGSize(width: containerRadius, height: containerRadius)
            )

            path.addRoundedRect(
                in: CGRect(
                    x: rect.midX - protrusionRadius,
                    y: 0,
                    width: protrusionRadius * 2,
                    height: rect.height
                ),
                cornerSize: CGSize(width: protrusionRadius, height: protrusionRadius)
            )

            path.addRoundedRect(
                in: CGRect(
                    x: 0,
                    y: rect.midY - protrusionRadius,
                    width: rect.width,
                    height: protrusionRadius * 2
                ),
                cornerSize: CGSize(width: protrusionRadius, height: protrusionRadius)
            )
        }
    }
}

#Preview {
    CalendarCellImageShape(
        containerPadding: 2.56,
        containerRadius: 4,
        protrusionRadius: 1.78
    )
    .frame(width: 100, height: 100)
}
