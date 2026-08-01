//
//  SolarTermCardView.swift
//  Presentation
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

struct SolarTermCardView: View {
    let card: SolarTermCard
    let solarTerm: SolarTerm
    let mission: CurrentMissionCard?
    let onMissionTap: () -> Void
    let onDetailTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 상단 텍스트 영역
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(card.startDate) - \(card.endDate)")
                        .font(.caption1Semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blackAlpha300)
                        .clipShape(Capsule())

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(descriptionLines(card.description), id: \.self) { line in
                            Text(line)
                                .font(.title2Bold)
                                .foregroundStyle(.white)
                        }
                    }

                    Button(action: onDetailTap) {
                        HStack(spacing: 0) {
                            Text("더보기")
                                .foregroundStyle(Color.white)
                                .font(.body2Medium)
                            Image.icArrowRight
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient.homeCardBackground(solarTerm.season))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // 하단 미션 카드
            MissionCardView(
                mission: mission,
                season: solarTerm.season,
                onMissionTap: onMissionTap
            )
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background {
            (solarTerm.cardImage)
                .resizable()
                .scaledToFill()
        }
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
    }
}

extension SolarTermCardView {
    func descriptionLines(_ description: String) -> [String] {
        let replace = description.replacingOccurrences(of: ",", with: ",\n")
        return replace.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
    }
}

private struct MissionCardView: View {
    let mission: CurrentMissionCard?
    let season: Season
    let onMissionTap: () -> Void

    private var title: String {
        mission?.title ?? "앗, 오늘의 미션이 비어있어요!"
    }

    private var buttonTitle: String {
        guard let mission else { return "제철 미션 기록하기" }
        return mission.isCompleted ? "미션을 기록했어요" : "미션 기록하기"
    }

    private var caption: String {
        guard let mission else { return "제철 미션에서 마음에 드는 제철 미션을 찾아보세요" }
        return "해당 미션에 \(mission.participantCount)명이 참여했어요"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.body1Semibold)
                    .foregroundStyle(mission != nil ? Color.gray900 : Color.gray600)

                Spacer()

                if mission?.isCompleted == true {
                    Image.icCheck
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(season.color(.scale500))
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(season.color(.scale300), lineWidth: 1)
                        )
                        .shadow(color: .blackAlpha200.opacity(0.0627), radius: 4)
                }
            }

            VStack(spacing: 8) {
                Button(buttonTitle, action: onMissionTap)
                    .buttonStyle(.seasonGradient(season))
                    .disabled(mission?.isCompleted == true)

                Text(caption)
                    .font(.caption1Regular)
                    .foregroundStyle(Color.gray600)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
        .overlay(
            RoundedRectangle(cornerRadius: .radius12)
                .stroke(season.color(.scale50), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    SolarTermCardView(
        card: HomeCard.mock.solarTerm,
        solarTerm: .ibha,
        mission: HomeCard.mock.currentMission,
        onMissionTap: {},
        onDetailTap: {}
    )
}
