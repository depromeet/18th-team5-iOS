//
//  SolarTerm+.swift
//  Data
//
//  Created by 이정원 on 5/28/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension SolarTerm {
    init?(_ value: String?) {
        let solarTerm = SolarTerm.allCases.first { $0.koreanName == value }
        guard let solarTerm else { return nil }
        self = solarTerm
    }
}
