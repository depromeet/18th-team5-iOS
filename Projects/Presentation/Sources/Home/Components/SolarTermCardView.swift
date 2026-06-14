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
    let solarTerm: SolarTermCard
    let mission: CurrentMissionCard?
    let onMissionTap: () -> Void
    let onDetailTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 상단 텍스트 영역
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(solarTerm.startDate) - \(solarTerm.endDate)")
                        .font(.caption1Semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blackAlpha300)
                        .clipShape(Capsule())

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(descriptionLines(solarTerm.description), id: \.self) { line in
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
                .background(LinearGradient.homeCardBackground(solarTerm.term?.season ?? .summer))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // 하단 미션 카드
            if let mission {
                MissionCardView(
                    mission: mission,
                    season: solarTerm.term?.season ?? .summer,
                    onMissionTap: onMissionTap
                )
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background {
            (solarTerm.term?.cardImage ?? Image.imgSolarTermCardDefault)
                .resizable()
                .scaledToFill()
        }
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
    }
}

extension SolarTermCardView {
    func descriptionLines(_ description: String) -> [String] {
        let replace = description.replacingOccurrences(of: ",", with: ",\n")
        return replace.split(separator: "\n").map { String($0) }
    }
}

private struct MissionCardView: View {
    let mission: CurrentMissionCard
    let season: Season
    let onMissionTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // 미션 제목
            HStack {
                Text(mission.title)
                    .font(.body1Semibold)
                    .foregroundStyle(Color.gray900)

                Spacer()

                if mission.isCompleted {
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
                Button(mission.isCompleted ? "미션을 기록했어요" : "미션 기록하기", action: onMissionTap)
                    .buttonStyle(.seasonGradient(season))
                    .disabled(mission.isCompleted)

                Text("해당 미션에 \(mission.participantCount)명이 참여했어요")
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
                .stroke(Color.green50, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    SolarTermCardView(
        solarTerm: HomeCard.mock.solarTerm,
        mission: HomeCard.mock.currentMission,
        onMissionTap: {},
        onDetailTap: {}
    )
}
