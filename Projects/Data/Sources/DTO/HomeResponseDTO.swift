//
//  HomeResponseDTO.swift
//  Data
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct HomeResponseDTO: Decodable {
    let code: String
    let message: String
    let result: HomeResultDTO
}

struct HomeResultDTO: Decodable {
    let solarTerm: SolarTermResponseDTO?
    let dailyMission: DailyMissionResponseDTO?
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

extension HomeResultDTO {
    func toDomain() -> HomeData {
        HomeData(
            solarTerm: solarTerm?.toDomain(),
            currentMission: dailyMission?.toDomain(),
            seasonRecord: .mock
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
