//
//  SolarTermRepositoryImpl.swift
//  Data
//
//  Created by choijunios on 5/17/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension SolarTermRepository: @retroactive DependencyKey {
    public static let liveValue: SolarTermRepository = SolarTermRepositoryImpl.live()
}

public enum SolarTermRepositoryImpl {
    public static func live() -> SolarTermRepository {
        SolarTermRepository(
            fetchSolarTerms: { year in
                guard let url = Bundle.module.url(
                    forResource: "solar_term_\(year.rawValue)",
                    withExtension: "json"
                )
                else {
                    throw DomainError.notFound
                }

                let data = try Data(contentsOf: url)
                let dto = try JSONDecoder().decode(SolarTermFileDTO.self, from: data)
                return dto.toDomain()
            }
        )
    }
}
