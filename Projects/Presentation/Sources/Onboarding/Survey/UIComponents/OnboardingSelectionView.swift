//
//  OnboardingSelectionView.swift
//  Presentation
//
//  Created by 이정원 on 5/5/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

private typealias Selection = OnboardingSurveyFeature.Selection

struct OnboardingSelectionView: View {
    private let title: (Selection) -> String
    private let subtitle: (Selection) -> String
    @Binding private var selection: Selection?

    init(
        title: @escaping (OnboardingSurveyFeature.Selection) -> String,
        subtitle: @escaping (OnboardingSurveyFeature.Selection) -> String,
        selection: Binding<OnboardingSurveyFeature.Selection?>
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            cardView(selection: .left)
            cardView(selection: .right)
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
    func cardView(selection: Selection) -> some View {
        cardView(
            title: title(selection),
            subtitle: subtitle(selection),
            isSelected: self.selection == selection,
            action: { self.selection = selection }
        )
    }

    func cardView(
        title: String?,
        subtitle: String?,
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
                    Text(title ?? "")
                        .font(.body1Semibold)
                        .foregroundStyle(titleColor(isSelected))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    Text(subtitle ?? "")
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
