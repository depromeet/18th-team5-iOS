//
//  SolarTermIntroFileDTO.swift
//  Data
//
//  Created by 송민교 on 5/19/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct SolarTermIntroFileDTO: Decodable {
    let solarTerms: [SolarTermIntroEntryDTO]
}

struct SolarTermIntroEntryDTO: Decodable {
    let id: String
    let introTitle: String
    let introSubtitle: String
    let title: String
    let meaning: String
    let characteristic: String
    let contentTitle: String
    let contentBody: String
    let contents: [SolarTermIntroContentDTO]
}

struct SolarTermIntroContentDTO: Decodable {
    let id: String
    let title: String
    let subtitle: String
    let imageURL: String
    let body: String
}

// MARK: - Domain Mapping

extension SolarTermIntroFileDTO {
    func toDomain() -> [SolarTermIntro] {
        solarTerms.map { $0.toDomain() }
    }
}

extension SolarTermIntroEntryDTO {
    func toDomain() -> SolarTermIntro {
        SolarTermIntro(
            term: SolarTerm(rawValue: id) ?? .ipchun,
            introTitle: introTitle,
            introSubtitle: introSubtitle,
            title: title,
            meaning: meaning,
            characteristic: characteristic,
            contentTitle: contentTitle,
            contentBody: contentBody,
            contents: contents.map { $0.toDomain() }
        )
    }
}

extension SolarTermIntroContentDTO {
    func toDomain() -> SolarTermIntroContent {
        SolarTermIntroContent(
            id: id,
            title: title,
            subtitle: subtitle,
            imageURL: imageURL,
            body: body
        )
    }
}
