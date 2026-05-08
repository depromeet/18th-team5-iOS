//
//  OnboardingSelectionView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct OnboardingSelectionView<Item: Hashable>: View {
    private let items: [Item]
    private let title: (Item) -> String
    private let subtitle: (Item) -> String
    @Binding private var selection: Item?

    init(
        items: [Item],
        title: @escaping (Item) -> String,
        subtitle: @escaping (Item) -> String,
        selection: Binding<Item?>
    ) {
        self.items = items
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(items, id: \.self) { item in
                itemView(item)
            }
        }
    }
}

private extension OnboardingSelectionView {
    func iconColor(_ isSelected: Bool) -> Color {
        isSelected ? .init(hex: 0x0077FF) : .init(hex: 0x1A1C20)
    }

    func titleColor(_ isSelected: Bool) -> Color {
        isSelected ? .init(hex: 0x0077FF) : .gray900
    }

    func backgroundColor(_ isSelected: Bool) -> Color {
        isSelected ? .init(hex: 0x0077FF, alpha: 0.05) : .white
    }

    func strokeColor(_ isSelected: Bool) -> Color {
        isSelected ? .init(hex: 0x0077FF) : .gray300
    }
}

private extension OnboardingSelectionView {
    func itemView(_ item: Item) -> some View {
        itemView(
            title: title(item),
            subtitle: subtitle(item),
            isSelected: item == selection,
            action: { selection = item }
        )
    }

    func itemView(
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                Image.icDashedBorderSquare
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(iconColor(isSelected))

                VStack(spacing: 6) {
                    Text(title)
                        .font(.body1Semibold)
                        .foregroundStyle(titleColor(isSelected))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.body2Regular)
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
            .background(backgroundColor(isSelected))
            .clipShape(RoundedRectangle(cornerRadius: .radius12))
            .overlay(RoundedRectangle(cornerRadius: .radius12).stroke(strokeColor(isSelected)))
        }
    }
}
