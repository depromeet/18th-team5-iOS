//
//  SolarTermIntroRepositoryImpl.swift
//  Data
//
//  Created by 송민교 on 5/19/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension SolarTermIntroRepository: @retroactive DependencyKey {
    public static let liveValue: SolarTermIntroRepository = SolarTermIntroRepositoryImpl.live()
}

public enum SolarTermIntroRepositoryImpl {
    public static func live() -> SolarTermIntroRepository {
        SolarTermIntroRepository(
            fetchSolarTermCard: {
                guard let url = Bundle.module.url(forResource: "solar_terms", withExtension: "json") else {
                    throw DomainError.notFound
                }
                let data = try Data(contentsOf: url)
                let dto = try JSONDecoder().decode(SolarTermIntroFileDTO.self, from: data)
                return dto.toDomain()
            }
        )
    }
}
