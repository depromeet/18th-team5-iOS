//
//  MissionAvailabilityResponseDTO.swift
//  Data
//
//  Created by 이정원 on 6/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

struct MissionAvailabilityResponseDTO: Decodable {
    let available: Bool?
    let completedCount: Int?
    let maxCount: Int?
    let remainingCount: Int?
}

extension MissionAvailabilityResponseDTO {
    var toDomain: MissionAvailability {
        .init(isAvailable: available, maxCount: maxCount)
    }
}
