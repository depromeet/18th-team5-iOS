//
//  MissionSearchRequestDTO.swift
//  Data
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

struct MissionSearchRequestDTO: Encodable {
    let spaceType: String?
    let companionType: String?
    let categoryType: String?

    init(attribute: MissionAttribute) {
        self.spaceType = attribute.locationType?.value
        self.companionType = attribute.participationType?.value
        self.categoryType = attribute.category?.value
    }
}
