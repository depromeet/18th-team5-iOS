//
//  PickerMissionCardView.swift
//  Presentation
//
//  Created by 이정원 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct PickerMissionCardView: View {
    fileprivate enum CardType {
        case active
        case `default`
        case disabled
    }

    private let mission: Mission
    private let season: Season
    private let cardType: CardType
    private let action: () -> Void

    init(
        mission: Mission,
        season: Season,
        isActive: Bool,
        action: @escaping () -> Void
    ) {
        self.mission = mission
        self.season = season
        self.action = action

        if mission.isCompleted {
            self.cardType = .disabled
        } else {
            self.cardType = isActive ? .active : .default
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                categoryIconView

                VStack(spacing: 0) {
                    categoryNameView
                    missionNameView
                }

                if mission.isCompleted {
                    checkMarkView
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 20)
            .frame(height: 80)
            .background { backgroundView }
            .clipShape(RoundedRectangle(cornerRadius: .radius16))
            .shadow(cardType)
            .overlay(RoundedRectangle(cornerRadius: .radius16).stroke(borderColor))
        }
        .disabled(cardType == .disabled)
    }
}

private extension PickerMissionCardView {
    var categoryIcon: Image? {
        guard let theme = mission.theme else { return nil }
        return switch theme {
        case .activity: .icTree
        case .food: .icFood
        case .contents: .icSlate
        }
    }

    var activeBackgroundImage: Image {
        switch season {
        case .spring: .imgGraphicSpring
        case .summer: .imgGraphicSummer
        case .autumn: .imgGraphicAutumn
        case .winter: .imgGraphicWinter
        }
    }

    var categoryTextColor: Color {
        switch cardType {
        case .active, .default: .gray600
        case .disabled: .gray500
        }
    }

    var missionNameColor: Color {
        switch cardType {
        case .active, .default: .gray900
        case .disabled: .gray500
        }
    }

    var borderColor: Color {
        switch cardType {
        case .active: season.color(.scale400)
        case .default, .disabled: .gray200
        }
    }
}

private extension PickerMissionCardView {
    @ViewBuilder
    var categoryIconView: some View {
        if let categoryIcon {
            categoryIcon
                .resizable()
                .frame(width: 24, height: 24)
        }
    }

    var categoryNameView: some View {
        Text(mission.theme?.name ?? "")
            .font(.caption1Medium)
            .foregroundStyle(categoryTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var missionNameView: some View {
        Text(mission.title)
            .font(.body1Semibold)
            .foregroundStyle(missionNameColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var checkMarkView: some View {
        ZStack {
            Color.whiteAlpha500

            Image.icCheck
                .renderingMode(.template)
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundStyle(season.color(.scale500))
        }
        .frame(width: 28, height: 28)
        .clipShape(RoundedRectangle(cornerRadius: .radius8))
        .overlay(
            RoundedRectangle(cornerRadius: .radius8)
                .stroke(season.color(.scale300))
        )
    }

    @ViewBuilder
    var backgroundView: some View {
        switch cardType {
        case .active: activeBackgroundView
        case .default, .disabled: Color.white
        }
    }

    var activeBackgroundView: some View {
        ZStack(alignment: .trailing) {
            Color.gray50
                .frame(maxWidth: .infinity)
                .frame(height: 80)

            activeBackgroundImage
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .padding(.trailing, 20)
        }
    }
}

private extension View {
    @ViewBuilder
    func shadow(_ cardType: PickerMissionCardView.CardType) -> some View {
        switch cardType {
        case .active:
            self.shadow(color: .blackAlpha200, radius: 10, x: 0, y: 8)
        case .default, .disabled: self
        }
    }
}
