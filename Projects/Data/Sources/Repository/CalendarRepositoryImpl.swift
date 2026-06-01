//
//  CalendarRepositoryImpl.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension CalendarRepository: @retroactive DependencyKey {
    public static let liveValue: CalendarRepository = CalendarRepositoryImpl.live()
}

public enum CalendarRepositoryImpl {
    public static func live() -> CalendarRepository {
        CalendarRepository(
            fetchCurrentSolarTerms: {
                @Dependency(\.networkClient) var client
                let response: CalendarSolarTermsResponseDTO? = try await client.request(
                    CalendarEndpoint.fetchCurrentSolarTerms
                )
                guard let response else {
                    throw DomainError.unknown("데이터 획득 실패")
                }
                return response.toDomain()
            },
            fetchSolarTerms: { solarTermId in
                @Dependency(\.networkClient) var client
                let response: CalendarSolarTermsResponseDTO? = try await client.request(
                    CalendarEndpoint.fetchSolarTerms(solarTermId: solarTermId)
                )
                guard let response else {
                    throw DomainError.unknown("데이터 획득 실패")
                }
                return response.toDomain()
            }
        )
    }
}

// MARK: - Domain Mapping

private extension CalendarSolarTermsResponseDTO {
    func toDomain() -> CalendarSolarTermsResponse {
        CalendarSolarTermsResponse(
            solarTerms: solarTerms.map { $0.toDomain() },
            prevSolarTermId: prevSolarTermId,
            nextSolarTermId: nextSolarTermId
        )
    }
}

private extension CalendarSolarTermDTO {
    func toDomain() -> CalendarSolarTerm {
        CalendarSolarTerm(
            solarTermId: solarTermId,
            solarTermInfo: toSolarTermInfo(),
            dates: dates.map { $0.toDomain() }
        )
    }

    // TODO: 임시 매핑 로직. name 매칭/연도 파싱 실패 시 fallback(.ipchun/.current)을 사용하므로 추후 보완 필요 -@준영
    func toSolarTermInfo() -> SolarTermInfo {
        let start = DateFormatter.yyyyMMdd.date(from: startDate) ?? Date()
        let end = DateFormatter.yyyyMMdd.date(from: endDate) ?? Date()
        let year = Int(startDate.prefix(4)).flatMap(SolarTermYear.init(rawValue:)) ?? .current
        let term = SolarTerm.allCases.first { $0.koreanName == name } ?? .ipchun
        return SolarTermInfo(year: year, term: term, startDate: start, endDate: end)
    }
}

private extension CalendarSolarTermDateDTO {
    func toDomain() -> CalendarSolarTermDate {
        CalendarSolarTermDate(
            date: DateFormatter.yyyyMMdd.date(from: date) ?? Date(),
            thumbnailURL: thumbnailUrl.flatMap { URL(string: $0) }
        )
    }
}

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
