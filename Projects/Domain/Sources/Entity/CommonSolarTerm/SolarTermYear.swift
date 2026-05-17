//
//  SolarTermYear.swift
//  Domain
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public enum SolarTermYear: Int, CaseIterable, Sendable, Equatable {
    case y2024 = 2024
    case y2025 = 2025
    case y2026 = 2026
}

public extension SolarTermYear {
    var nextYear: Self? {
        SolarTermYear(rawValue: rawValue + 1)
    }

    var prevYear: Self? {
        SolarTermYear(rawValue: rawValue - 1)
    }
}
