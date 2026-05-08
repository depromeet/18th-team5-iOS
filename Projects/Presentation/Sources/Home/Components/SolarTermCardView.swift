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
    let onDetailTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // 배경 + 장식 이미지 (overlay로 레이아웃 영향 차단)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: 0xA9EEC8))
                .frame(height: 400)
                .overlay(alignment: .topLeading) {
                    Image.homeDiamond
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 346, height: 346)
                        .padding(.leading, 20)
                }
                .overlay {
                    Image.homeLine
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 1332, height: 520)
                        .rotationEffect(.degrees(-10))
                        .offset(x: -30, y: 15)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

            // 상단 그라디언트 오버레이
            VStack {
                LinearGradient(
                    colors: [Color(hex: 0x35B26D), Color(hex: 0x35B26D).opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 234)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

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
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private func formattedDate(_ dateString: String) -> String {
    let parts = dateString.split(separator: "-")
    guard parts.count == 3 else { return dateString }
    return "\(parts[1]).\(parts[2])"
}

private func descriptionLines(_ description: String) -> [String] {
    let parts = description.components(separatedBy: ", ")
    guard parts.count == 2 else { return [description] }
    return [parts[0] + ",", parts[1]]
}

private struct MissionCardView: View {
    let mission: CurrentMissionCard
    let onMissionTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(mission.title)
                .font(.body1Semibold)
                .foregroundStyle(Color(hex: 0x1D293D))

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
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 15)
        .frame(width: 313)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    SolarTermCardView(
        solarTerm: HomeData.mock.solarTerm!,
        mission: HomeData.mock.currentMission!,
        onMissionTap: {},
        onDetailTap: {}
    )
}
