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
                    SearchCategoryChipView(
                        title: itemTitle(item),
                        image: itemImage(item),
                        season: season,
                        isSelected: item == selection,
                        action: { selection = item }
                    )
                }
            }
        }
    }
}
