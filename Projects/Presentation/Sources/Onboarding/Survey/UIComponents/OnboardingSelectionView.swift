//
//  OnboardingSelectionView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct OnboardingSelectionViewState {
    let title: String
    let subtitle: String
    let image: Image
}

struct OnboardingSelectionView<Item: Hashable>: View {
    private let items: [Item]
    private let viewState: (Item) -> OnboardingSelectionViewState
    @Binding private var selection: Item?

    init(
        items: [Item],
        viewState: @escaping (Item) -> OnboardingSelectionViewState,
        selection: Binding<Item?>
    ) {
        self.items = items
        self.viewState = viewState
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
        isSelected ? .init(hex: 0x3DC67B) : .gray900
    }

    func backgroundColor(_ isSelected: Bool) -> Color {
        isSelected ? .init(hex: 0x43DA87, alpha: 0.05) : .white
    }

    func strokeColor(_ isSelected: Bool) -> Color {
        isSelected ? .init(hex: 0x43DA87) : .gray300
    }
}

private extension OnboardingSelectionView {
    func itemView(_ item: Item) -> some View {
        itemView(
            viewState: viewState(item),
            isSelected: item == selection,
            action: { selection = item }
        )
    }

    func itemView(
        viewState: OnboardingSelectionViewState,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                viewState.image
                    .resizable()
                    .frame(width: 32, height: 32)

                VStack(spacing: 6) {
                    Text(viewState.title)
                        .font(.body1Semibold)
                        .foregroundStyle(titleColor(isSelected))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    Text(viewState.subtitle)
                        .font(.body2Regular)
                        .foregroundStyle(Color.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
            .background(backgroundColor(isSelected))
            .clipShape(RoundedRectangle(cornerRadius: .radius16))
            .overlay(RoundedRectangle(cornerRadius: .radius16).stroke(strokeColor(isSelected)))
        }
    }
}
