//
//  SolarTermFileDTO.swift
//  Data
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct SolarTermFileDTO: Decodable {
    let year: Int
    let terms: [SolarTermEntryDTO]
}

struct SolarTermEntryDTO: Decodable {
    let id: String
    let month: Int
    let day: Int
}
