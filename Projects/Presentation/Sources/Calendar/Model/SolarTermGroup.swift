//
//  SolarTermGroup.swift
//  Presentation
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

public struct SolarTermGroup: Identifiable, Equatable {
    public let id: String
    public let solarTermInfo: SolarTermInfo
    public let cells: [[SolarTermGroupCell]]
}

public enum SolarTermGroupCell: Identifiable, Equatable {
    case emptyCell(id: String)
    case dateCell(SolarTermDate)

    public var id: String {
        switch self {
        case let .emptyCell(id): id
        case let .dateCell(info): info.id
        }
    }
}

public struct SolarTermDate: Identifiable, Equatable {
    public let id: String
    public let dayText: String
    public var isToday: Bool
}
