//
//  MissionResponseDTO.swift
//  Data
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

struct MissionResponseDTO: Decodable {
    let id: Int?
    let title: String?
    let description: String?
    let spaceType: String?
    let intensityType: String?
    let companionType: String?
    let categoryType: String?
    let enjoyType: String?
    let isCompleted: Bool?
}

extension MissionResponseDTO {
    var searchedMission: Mission? {
        guard let id,
              let title else {
            return nil
        }

        return Mission(
            id: id,
            title: title,
            description: description,
            attribute: MissionAttribute(
                locationType: LocationType(spaceType),
                participationType: ParticipationType(companionType),
                category: MissionCategory(categoryType)
            )
        )
    }

    var recommendedMission: Mission? {
        guard let id,
              let title else {
            return nil
        }

        return .init(
            id: id,
            title: title,
            theme: MissionTheme(enjoyType),
            isCompleted: isCompleted
        )
    }
}
