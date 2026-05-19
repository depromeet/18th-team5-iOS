//
//  HomeCard.swift
//  Domain
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct HomeCard: Equatable {
    public let solarTerm: SolarTermCard
    public let currentMission: CurrentMissionCard?

    public init(
        solarTerm: SolarTermCard,
        currentMission: CurrentMissionCard?
    ) {
        self.solarTerm = solarTerm
        self.currentMission = currentMission
    }
}

public extension HomeCard {
    static let mock = HomeCard(
        solarTerm: SolarTermCard(
            id: 9,
            name: "입하",
            description: "여름이 일어서는 시간, 입하예요",
            startDate: "2026-05-05",
            endDate: "2026-05-20"
        ),
        currentMission: CurrentMissionCard(
            id: 7,
            title: "시원한 계곡물에 발 담그기",
            participantCount: 100,
            missionType: "DAILY"
        )
    )
}
