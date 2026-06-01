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
    private let viewState: (Item) -> OnboardingViewState
    @Binding private var selection: Item?

    init(
        items: [Item],
        viewState: @escaping (Item) -> OnboardingViewState,
        selection: Binding<Item?>
    ) {
        self.items = items
        self.viewState = viewState
        self._selection = selection
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(items, id: \.self) { item in
                itemView(item)
            }
        }
    }
}

private extension OnboardingSelectionView {
    func titleColor(_ isSelected: Bool) -> Color {
        isSelected ? .green600 : .gray900
    }

    func backgroundColor(_ isSelected: Bool) -> Color {
        isSelected ? .green500.opacity(0.04) : .white
    }

    func strokeColor(_ isSelected: Bool) -> Color {
        isSelected ? .green300 : .gray300
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
        viewState: OnboardingViewState,
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
