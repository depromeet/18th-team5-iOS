//
//  CalendarRepository.swift
//  Domain
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct CalendarRepository: Sendable {
    /// 현재 절기 캘린더 조회 (오늘 날짜 기준 현재 + 다음 절기 2개)
    public var fetchCurrentSolarTerms: @Sendable () async throws -> CalendarSolarTermsResponse
    /// 절기 캘린더 조회 (페이지네이션, 시작 절기 ID 기준 2개)
    public var fetchSolarTerms: @Sendable (_ solarTermId: Int) async throws -> CalendarSolarTermsResponse
}

extension CalendarRepository: TestDependencyKey {
    public static let testValue = CalendarRepository()
}

public extension DependencyValues {
    var calendarRepository: CalendarRepository {
        get { self[CalendarRepository.self] }
        set { self[CalendarRepository.self] = newValue }
    }
}

public extension CalendarRepository {
    static let previewValue = CalendarRepository(
        fetchCurrentSolarTerms: {
            CalendarSolarTermsResponse(
                fetchedSolarTerms: [],
                prevSolarTerm: nil,
                nextSolarTerm: nil
            )
        },
        fetchSolarTerms: { _ in
            CalendarSolarTermsResponse(
                fetchedSolarTerms: [],
                prevSolarTerm: nil,
                nextSolarTerm: nil
            )
        }
    )
}
