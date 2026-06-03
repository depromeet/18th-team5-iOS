//
//  OnboardingRankingView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct OnboardingRankingView<Item: Hashable>: View {
    @Binding private var ranking: [Item]
    private let items: [Item]
    private let viewState: (Item) -> OnboardingViewState

    init(
        items: [Item],
        ranking: Binding<[Item]>,
        viewState: @escaping (Item) -> OnboardingViewState
    ) {
        self.items = items
        self._ranking = ranking
        self.viewState = viewState
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    itemView(item: item) {
                        if ranking.contains(item) {
                            ranking.removeAll { $0 == item }
                        } else {
                            ranking.append(item)
                        }
                    }
                }
            }

            resetButton
        }
    }
}

private extension OnboardingRankingView {
    func backgroundColor(_ isSelected: Bool) -> Color {
        isSelected ? .green500.opacity(0.04) : .white
    }

    func strokeColor(_ isSelected: Bool) -> Color {
        isSelected ? .green300 : .gray300
    }
}

private extension OnboardingRankingView {
    func itemView(
        item: Item,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            let rank = ranking.firstIndex(of: item)
            let viewState = viewState(item)
            let isSelected = rank != nil

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        viewState.image
                            .resizable()
                            .frame(width: 20, height: 20)

                        Text(viewState.title)
                            .font(.body1Semibold)
                            .foregroundStyle(Color.gray900)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }

                    Text(viewState.subtitle)
                        .font(.body2Regular)
                        .foregroundStyle(Color.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }

                if let rank {
                    Text("\(rank + 1)순위")
                        .font(.body2Medium)
                        .foregroundStyle(Color.green600)
                        .frame(height: 26)
                        .padding(.horizontal, 7)
                        .background(Color.blackAlpha200)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(20)
            .background(backgroundColor(isSelected))
            .clipShape(RoundedRectangle(cornerRadius: .radius12))
            .overlay(RoundedRectangle(cornerRadius: .radius12).stroke(strokeColor(isSelected)))
        }
    }

    var resetButton: some View {
        let isEnabled = !ranking.isEmpty
        let textColor: Color = isEnabled ? .gray900 : .white
        let backgroundColor: Color = isEnabled ? .gray200 : .gray400

        return Button {
            ranking.removeAll()
        } label: {
            Text("초기화")
                .font(.body2Medium)
                .foregroundStyle(textColor)
                .frame(height: 32)
                .padding(.horizontal, 12)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
    }
}
