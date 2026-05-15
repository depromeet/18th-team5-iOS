//
//  HomeResponseDTO.swift
//  Data
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct HomeCardDTO: Decodable {
    let solarTerm: SolarTermResponseDTO
    let dailyMission: DailyMissionResponseDTO
}

struct SolarTermResponseDTO: Decodable {
    let id: Int
    let name: String
    let description: String
    let startDate: String
    let endDate: String
}

struct DailyMissionResponseDTO: Decodable {
    let id: Int
    let title: String
    let participantCount: Int
    let missionType: String
}

// MARK: - Domain Mapping

extension HomeCardDTO {
    func toDomain() -> HomeCard {
        HomeCard(
            solarTerm: solarTerm.toDomain(),
            currentMission: dailyMission.toDomain()
        )
    }
}

extension SolarTermResponseDTO {
    func toDomain() -> SolarTermCard {
        SolarTermCard(
            id: id,
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate
        )
    }
}

extension DailyMissionResponseDTO {
    func toDomain() -> CurrentMissionCard {
        CurrentMissionCard(
            id: id,
            title: title,
            participantCount: participantCount,
            missionType: missionType
        )
    }
}
