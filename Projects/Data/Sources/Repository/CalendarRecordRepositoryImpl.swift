//
//  CalendarRecordRepositoryImpl.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

extension CalendarRecordRepository: @retroactive DependencyKey {
    public static let liveValue: CalendarRecordRepository = CalendarRecordRepositoryImpl.live()
}

public enum CalendarRecordRepositoryImpl {
    public static func live() -> CalendarRecordRepository {
        CalendarRecordRepository(
            fetchCurrentSolarTerms: {
                @Dependency(\.networkClient) var client
                let response: CalendarTermRecordsResponseDTO? = try await client.request(
                    CalendarEndpoint.fetchCurrentSolarTerms
                )
                guard let response else {
                    throw DomainError.unknown("데이터 획득 실패")
                }
                return response.toDomain()
            },
            fetchSolarTerms: { solarTermId in
                @Dependency(\.networkClient) var client
                let response: CalendarTermRecordsResponseDTO? = try await client.request(
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

private extension CalendarTermRecordsResponseDTO {
    func toDomain() -> CalendarTermRecordsResponse {
        let records = solarTerms.map { $0.toDomain() }
        return CalendarTermRecordsResponse(
            fetchedTermRecords: records.sortedByCalendarOrder(),
            prevTermEmptyRecord: CalendarTermRecord.pageAnchor(
                id: prevSolarTermId,
                boundary: records.first,
                direction: .previous
            ),
            nextTermEmptyRecord: CalendarTermRecord.pageAnchor(
                id: nextSolarTermId,
                boundary: records.last,
                direction: .next
            )
        )
    }
}

private extension CalendarTermRecordDTO {
    func toDomain() -> CalendarTermRecord {
        CalendarTermRecord(
            solarTermId: solarTermId,
            term: toSolarTerm(),
            year: toSolarTermYear(),
            dates: dates.map { $0.toDomain() }
        )
    }

    // TODO: 임시 매핑 로직. name 매칭/연도 파싱 실패 시 fallback(.ipchun/.current)을 사용하므로 추후 보완 필요 -@준영
    func toSolarTermYear() -> SolarTermYear {
        Int(startDate.prefix(4))
            .flatMap(SolarTermYear.init(rawValue:)) ?? .current
    }

    func toSolarTerm() -> SolarTerm {
        SolarTerm.allCases.first { $0.koreanName == name } ?? .ipchun
    }
}

private extension CalendarDateRecordDTO {
    func toDomain() -> CalendarDateRecord {
        CalendarDateRecord(
            date: DateFormatter.yyyyMMdd.date(from: date) ?? Date(),
            thumbnailURL: thumbnailUrl.flatMap { URL(string: $0) }
        )
    }
}

// MARK: - 페이지네이션 앵커 계산

/// 절기 캘린더 페이지 이동 방향
private enum PageDirection {
    case previous
    case next
}

private extension CalendarTermRecord {
    /// 경계 기록(boundary)의 인접 절기를 주어진 id에 매핑해 페이지 앵커 기록을 생성합니다.
    /// id·boundary가 없거나 인접 절기를 구할 수 없으면 nil을 반환합니다.
    static func pageAnchor(
        id: Int?,
        boundary: CalendarTermRecord?,
        direction: PageDirection
    ) -> CalendarTermRecord? {
        guard let id,
              let adjacent = boundary?.adjacentTerm(direction)
        else { return nil }

        return CalendarTermRecord(
            solarTermId: id,
            term: adjacent.term,
            year: adjacent.year,
            dates: []
        )
    }

    /// 같은 해의 인접 절기를 우선 반환하고, 연도 경계를 넘으면 인접 연도의 첫/마지막 절기를 반환합니다.
    func adjacentTerm(_ direction: PageDirection) -> (term: SolarTerm, year: SolarTermYear)? {
        switch direction {
        case .previous:
            if let prev = term.prevTermInYear() {
                return (prev, year)
            }
            guard let prevYear = year.prevYear else { return nil }
            return (.lastStartTermInYear, prevYear)

        case .next:
            if let next = term.nextTermInYear() {
                return (next, year)
            }
            guard let nextYear = year.nextYear else { return nil }
            return (.firstStartTermInYear, nextYear)
        }
    }
}

private extension [CalendarTermRecord] {
    /// 연도 → 절기 순서(orderIndex) 기준으로 정렬합니다.
    func sortedByCalendarOrder() -> [CalendarTermRecord] {
        sorted { lhs, rhs in
            if lhs.year == rhs.year {
                return lhs.term.yearOrder < rhs.term.yearOrder
            }
            return lhs.year.rawValue < rhs.year.rawValue
        }
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
