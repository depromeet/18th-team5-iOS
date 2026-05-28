//
//  RecommendedMissionResponseDTO.swift
//  Data
//
//  Created by 이정원 on 5/28/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

struct RecommendedMissionResponseDTO: Decodable {
    let userType: String?
    let solarTerm: String?
    let missions: [MissionResponseDTO]?
}

struct RecommendedMissionHeaderDTO: Decodable {
    let title: String?
    let subtitle: String?
}

extension RecommendedMissionResponseDTO {
    var toDomain: RecommendedMission {
        let missions = missions?
            .compactMap(\.recommendedMission)
            .sorted {
                switch ($0.theme?.order, $1.theme?.order) {
                case let (lhs?, rhs?): return lhs < rhs
                default: return false
                }
            } ?? []

        return .init(
            userType: UserType(userType),
            solarTerm: SolarTerm(solarTerm),
            missions: missions
        )
    }
}
