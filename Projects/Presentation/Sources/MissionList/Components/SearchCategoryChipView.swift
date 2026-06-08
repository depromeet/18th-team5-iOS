//
//  SearchCategoryChipView.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct SearchCategoryChipView: View {
    private let title: String
    private let image: Image
    private let season: Season
    private let isSelected: Bool
    private let action: (() -> Void)?

    init(
        title: String,
        image: Image,
        season: Season,
        isSelected: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.image = image
        self.season = season
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 4) {
                image
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray900)
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(backgroundColor(isSelected))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(borderColor(isSelected)))
        }
    }
}

private extension SearchCategoryChipView {
    func backgroundColor(_ isSelected: Bool) -> Color {
        isSelected ? season.color(.scale500).opacity(0.05) : .white
    }

    func borderColor(_ isSelected: Bool) -> Color {
        isSelected ? season.color(.scale300) : .gray300
    }
}
