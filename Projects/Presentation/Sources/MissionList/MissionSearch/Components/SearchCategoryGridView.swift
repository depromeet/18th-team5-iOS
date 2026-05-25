//
//  SearchCategoryGridView.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct SearchCategoryGridView<Item: Hashable>: View {
    @Binding private var selection: Item?
    private let title: String
    private let season: Season
    private let items: [Item]
    private let itemTitle: (Item) -> String
    private let itemImage: (Item) -> Image

    init(
        title: String,
        season: Season,
        items: [Item],
        selection: Binding<Item?>,
        itemTitle: @escaping (Item) -> String,
        itemImage: @escaping (Item) -> Image
    ) {
        self.title = title
        self.season = season
        self.items = items
        self._selection = selection
        self.itemTitle = itemTitle
        self.itemImage = itemImage
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.body2Semibold)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: .init(repeating: .init(.fixed(73), spacing: 6), count: 4),
                alignment: .leading,
                spacing: 6
            ) {
                ForEach(items, id: \.self) { item in
                    chipView(
                        title: itemTitle(item),
                        image: itemImage(item),
                        isSelected: item == selection
                    ) {
                        selection = item
                    }
                }
            }
        }
    }
}

private extension SearchCategoryGridView {
    func backgroundColor(_ isSelected: Bool) -> Color {
        isSelected ? season.backgroundColor : .white
    }

    func borderColor(_ isSelected: Bool) -> Color {
        isSelected ? season.borderColor : .gray300
    }
}

private extension SearchCategoryGridView {
    func chipView(
        title: String,
        image: Image,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                image
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.body2Regular)
                    .foregroundStyle(Color.gray900)
            }
            .frame(width: 73, height: 36)
            .background(backgroundColor(isSelected))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(borderColor(isSelected)))
        }
    }
}

private extension Season {
    var backgroundColor: Color {
        let color: Color = switch self {
        case .spring: .pink500
        case .summer: .green500
        case .autumn: .orange500
        case .winter: .blue500
        }
        return color.opacity(0.05)
    }

    var borderColor: Color {
        switch self {
        case .spring: .pink300
        case .summer: .green300
        case .autumn: .orange300
        case .winter: .blue300
        }
    }
}
