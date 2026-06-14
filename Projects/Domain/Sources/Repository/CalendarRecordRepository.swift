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
    /// 날짜별 기록 조회 (해당 날짜의 모든 기록 카드)
    public var fetchDateRecords: @Sendable (_ date: Date) async throws -> [DateRecordCard]
    /// 미션 기록 삭제 (모든 절기 삭제 가능)
    public var deleteMissionCompletion: @Sendable (_ completionId: Int) async throws -> Void
    /// 자유 기록 삭제 (모든 절기 삭제 가능)
    public var deleteFreeRecord: @Sendable (_ recordId: Int) async throws -> Void
    /// 자유 기록 추가
    public var completeFreeRecord: @Sendable (
        _ recordDate: String,
        _ objectKey: String,
        _ memo: String?
    ) async throws -> Int
    /// 미션 기록 수정
    public var updateMissionCompletion: @Sendable (
        _ completionId: Int,
        _ objectKey: String,
        _ memo: String?
    ) async throws -> Void
    /// 자유 기록 수정
    public var updateFreeRecord: @Sendable (
        _ recordId: Int,
        _ objectKey: String,
        _ memo: String?
    ) async throws -> Void
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
        fetchDateRecords: { _ in [] },
        deleteMissionCompletion: { _ in },
        deleteFreeRecord: { _ in },
        completeFreeRecord: { _, _, _ in 0 },
        updateMissionCompletion: { _, _, _ in },
        updateFreeRecord: { _, _, _ in }
    )
}
