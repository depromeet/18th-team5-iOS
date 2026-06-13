//
//  CalendarRecordRepository.swift
//  Domain
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct CalendarRecordRepository: Sendable {
    /// 현재 절기 캘린더 조회 (오늘 날짜 기준 현재 + 다음 절기 2개)
    public var fetchCurrentSolarTerms: @Sendable () async throws -> CalendarTermRecordsResponse
    /// 절기 캘린더 조회 (페이지네이션, 시작 절기 ID 기준 2개)
    public var fetchSolarTerms: @Sendable (_ solarTermId: Int) async throws -> CalendarTermRecordsResponse
    /// 자유 기록 추가
    public var completeFreeRecord: @Sendable (
        _ recordDate: String,
        _ objectKey: String,
        _ memo: String?
    ) async throws -> Int
}

extension CalendarRecordRepository: TestDependencyKey {
    public static let testValue = CalendarRecordRepository()
}

public extension DependencyValues {
    var calendarRecordRepository: CalendarRecordRepository {
        get { self[CalendarRecordRepository.self] }
        set { self[CalendarRecordRepository.self] = newValue }
    }
}

public extension CalendarRecordRepository {
    static let previewValue = CalendarRecordRepository(
        fetchCurrentSolarTerms: {
            CalendarTermRecordsResponse(
                fetchedTermRecords: [],
                prevTermEmptyRecord: nil,
                nextTermEmptyRecord: nil
            )
        },
        fetchSolarTerms: { _ in
            CalendarTermRecordsResponse(
                fetchedTermRecords: [],
                prevTermEmptyRecord: nil,
                nextTermEmptyRecord: nil
            )
        },
        completeFreeRecord: { _, _, _ in
            0
        }
    )
}
