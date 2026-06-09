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
    let isCompleted: Bool
}

// MARK: - Domain Mapping

extension HomeCardDTO {
    func toDomain() -> HomeCard {
        HomeCard(
            solarTerm: solarTerm.toDomain(),
            currentMission: dailyMission?.toDomain()
        )
    }
}

extension SolarTermResponseDTO {
    func toDomain() -> SolarTermCard {
        SolarTermCard(
            id: id,
            term: SolarTerm.allCases.first { $0.koreanName == name },
            name: name,
            description: description,
            startDate: Self.formatDateString(startDate),
            endDate: Self.formatDateString(endDate)
        )
    }

    /// "YYYY-MM-DD" → "MM.dd"
    private static func formatDateString(_ dateString: String) -> String {
        let parts = dateString.split(separator: "-")
        guard parts.count == 3 else { return dateString }
        return "\(parts[1]).\(parts[2])"
    }
}

extension DailyMissionResponseDTO {
    func toDomain() -> CurrentMissionCard {
        CurrentMissionCard(
            id: id,
            title: title,
            participantCount: participantCount,
            missionType: missionType,
            isCompleted: isCompleted
        )
    }
}
