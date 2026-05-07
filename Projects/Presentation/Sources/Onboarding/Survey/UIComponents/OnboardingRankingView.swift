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
    private let title: (Item) -> String
    private let subtitle: (Item) -> String

    init(
        items: [Item],
        ranking: Binding<[Item]>,
        title: @escaping (Item) -> String,
        subtitle: @escaping (Item) -> String
    ) {
        self.items = items
        self._ranking = ranking
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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

private extension OnboardingRankingView {
    func itemView(
        item: Item,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            let rank = ranking.firstIndex(of: item)
            let isSelected = rank != nil

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image.icDashedBorderSquare
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(iconColor(isSelected))

                        Text(title(item))
                            .font(.body1Semibold)
                            .foregroundStyle(titleColor(isSelected))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }

                    Text(subtitle(item))
                        .font(.body2Regular)
                        .foregroundStyle(Color(hex: 0x9CA3AF))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }

                if let rank {
                    Text("\(rank + 1)순위")
                        .font(.body2Regular)
                        .foregroundStyle(Color.gray900)
                        .frame(height: 24)
                        .padding(.horizontal, 8)
                        .background(Color(hex: 0xE5E7EB))
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
        let textColor: Color = isEnabled ? .gray800 : .white
        let backgroundColor: Color = isEnabled ? .gray200 : .gray400

        return Button {
            ranking.removeAll()
        } label: {
            Text("초기화")
                .font(.body2Regular)
                .foregroundStyle(textColor)
                .frame(height: 36)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
    }
}
