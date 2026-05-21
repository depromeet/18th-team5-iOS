//
//  SolarTermYear.swift
//  Domain
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum SolarTermYear: Int, CaseIterable, Sendable {
    case y2024 = 2024
    case y2025 = 2025
    case y2026 = 2026

    public static var current: SolarTermYear {
        let year = Calendar.current.component(.year, from: Date())
        return SolarTermYear(rawValue: year) ?? .y2026
    }

    public var previous: SolarTermYear? {
        SolarTermYear(rawValue: rawValue - 1)
    }
}
