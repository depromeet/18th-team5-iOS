//
//  MissionAvailability.swift
//  Domain
//
//  Created by 이정원 on 6/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public struct MissionAvailability: Equatable {
    public let isAvailable: Bool?
    public let maxCount: Int?

    public init(isAvailable: Bool?, maxCount: Int?) {
        self.isAvailable = isAvailable
        self.maxCount = maxCount
    }
}
