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
        isSelected ? .init(hex: 0x43DA87, alpha: 0.05) : .white
    }

    func strokeColor(_ isSelected: Bool) -> Color {
        isSelected ? .init(hex: 0x43DA87) : .gray300
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
                            .frame(width: 24, height: 24)

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
                        .foregroundStyle(Color(hex: 0x3DC67B))
                        .frame(height: 24)
                        .padding(.horizontal, 8)
                        .background(Color.blackAlpha200)
                        .clipShape(RoundedRectangle(cornerRadius: .radius4))
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
                .frame(height: 36)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
    }
}
