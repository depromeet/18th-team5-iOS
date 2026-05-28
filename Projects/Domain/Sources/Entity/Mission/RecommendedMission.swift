//
//  RecommendedMission.swift
//  Domain
//
//  Created by 이정원 on 5/28/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct RecommendedMission: Equatable {
    public let userType: UserType?
    public let solarTerm: SolarTerm?
    public let missions: [Mission]

    public init(
        userType: UserType?,
        solarTerm: SolarTerm?,
        missions: [Mission]
    ) {
        self.userType = userType
        self.solarTerm = solarTerm
        self.missions = missions
    }
}
