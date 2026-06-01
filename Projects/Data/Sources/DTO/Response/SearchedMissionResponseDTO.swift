//
//  SearchedMissionResponseDTO.swift
//  Data
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

struct SearchedMissionResponseDTO: Decodable {
    let hasSelected: Bool
    let mission: MissionResponseDTO?
}
