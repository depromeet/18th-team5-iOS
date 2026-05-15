//
//  SolarTermCard.swift
//  Domain
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct SolarTermCard: Equatable {
    public let id: Int
    public let name: String
    public let description: String
    public let startDate: String
    public let endDate: String

    public init(id: Int, name: String, description: String, startDate: String, endDate: String) {
        self.id = id
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
    }
}
