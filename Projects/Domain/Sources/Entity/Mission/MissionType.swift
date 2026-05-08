//
//  MissionType.swift
//  Domain
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum MissionType: String, Codable, Equatable, Sendable {
    case daily = "DAILY"
    case recommended = "RECOMMENDED"
    case selected = "SELECTED"
}
