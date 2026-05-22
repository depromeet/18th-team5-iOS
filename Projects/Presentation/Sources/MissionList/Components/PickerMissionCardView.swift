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
    private let cardType: CardType
    private let action: () -> Void

    init(
        mission: Mission,
        isActive: Bool,
        action: @escaping () -> Void
    ) {
        self.mission = mission
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
    var categoryIcon: Image {
        switch mission.category {
        case .activity: .icTree
        case .food: .icFood
        case .contents: .icSlate
        }
    }

    var activeBackgroundImage: Image {
        switch mission.season {
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
        case .active: activeBorderColor
        case .default, .disabled: .gray200
        }
    }

    var activeBorderColor: Color {
        switch mission.season {
        case .spring: .pink400
        case .summer: .green400
        case .autumn: .orange400
        case .winter: .blue400
        }
    }
}

private extension PickerMissionCardView {
    var categoryIconView: some View {
        categoryIcon
            .resizable()
            .frame(width: 24, height: 24)
    }

    var categoryNameView: some View {
        Text(mission.category.name)
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
                .foregroundStyle(mission.season.checkIconColor)
        }
        .frame(width: 28, height: 28)
        .clipShape(RoundedRectangle(cornerRadius: .radius8))
        .overlay(
            RoundedRectangle(cornerRadius: .radius8)
                .stroke(mission.season.borderColor)
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
            Color(hex: 0xF7F8F9)
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

private extension Season {
    var checkIconColor: Color {
        switch self {
        case .spring: .pink500
        case .summer: .green500
        case .autumn: .orange500
        case .winter: .blue500
        }
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
