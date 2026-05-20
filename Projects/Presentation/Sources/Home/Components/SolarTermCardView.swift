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
    let mission: CurrentMissionCard
    let onMissionTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Image.homeSeasonCard
                .resizable()

            // 상단 텍스트 영역
            VStack(alignment: .leading, spacing: 12) {
                Text("\(formattedDate(solarTerm.startDate)) - \(formattedDate(solarTerm.endDate))")
                    .font(.caption1Semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.13))
                    .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(descriptionLines(solarTerm.description), id: \.self) { line in
                        Text(line)
                            .font(.title2Bold)
                            .foregroundStyle(.white)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: 400, alignment: .topLeading)

            // 하단 미션 카드
            MissionCardView(
                mission: mission,
                onMissionTap: onMissionTap
            )
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: .radius16))
    }
}

extension SolarTermCardView {
    func formattedDate(_ dateString: String) -> String {
        let parts = dateString.split(separator: "-")
        guard parts.count == 3 else { return dateString }
        return "\(parts[1]).\(parts[2])"
    }

    func descriptionLines(_ description: String) -> [String] {
        let replace = description.replacingOccurrences(of: ", ", with: ",\n")
        return replace.split(separator: "\n").map { String($0) }
    }
}

private struct MissionCardView: View {
    let mission: CurrentMissionCard
    let onMissionTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(mission.title)
                .font(.body1Semibold)
                .foregroundStyle(Color(hex: 0x1A1C20))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                Button(action: onMissionTap) {
                    Text("미션 참여하기")
                        .font(.body1Medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: 0x43DA87), Color(hex: 0x3DC67B)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Text("해당 미션에 \(mission.participantCount)명이 참여했어요")
                    .font(.caption1Regular)
                    .foregroundStyle(Color(hex: 0x868B94))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 15)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: .radius12))
        .padding(.horizontal, 16)
    }
}

#Preview {
    SolarTermCardView(
        solarTerm: HomeCard.mock.solarTerm,
        mission: HomeCard.mock.currentMission,
        onMissionTap: {}
    )
}
