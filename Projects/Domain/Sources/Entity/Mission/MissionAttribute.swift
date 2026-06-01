//
//  MissionAttribute.swift
//  Domain
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct MissionAttribute: Equatable, Hashable {
    public let locationType: LocationType?
    public let participationType: ParticipationType?
    public let category: MissionCategory?

    public init(
        locationType: LocationType?,
        participationType: ParticipationType?,
        category: MissionCategory?
    ) {
        self.locationType = locationType
        self.participationType = participationType
        self.category = category
    }
}
