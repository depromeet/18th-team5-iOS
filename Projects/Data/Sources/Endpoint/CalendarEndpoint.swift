//
//  CalendarEndpoint.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

enum CalendarEndpoint: APIEndpoint {
    /// 현재 절기 캘린더 조회 (오늘 날짜 기준 현재 + 다음 절기)
    case fetchCurrentSolarTerms
    /// 절기 캘린더 조회 (페이지네이션, 시작 절기 ID 기준)
    case fetchSolarTerms(solarTermId: Int)
    /// 날짜별 기록 조회 (date: yyyy-MM-dd)
    case fetchDateRecords(date: String)
    /// 미션 기록 삭제
    case deleteMissionCompletion(completionId: Int)
    /// 자유 기록 삭제
    case deleteFreeRecord(recordId: Int)
    /// 자유 기록 추가
    case completeFreeRecord(CalendarFreeRecordRequestDTO)
    /// 미션 기록 수정
    case updateMissionCompletion(completionId: Int, request: CalendarRecordUpdateRequestDTO)
    /// 자유 기록 수정
    case updateFreeRecord(recordId: Int, request: CalendarRecordUpdateRequestDTO)

    var path: String {
        switch self {
        case .fetchCurrentSolarTerms:
            "/api/v1/calendar/solar-terms"
        case let .fetchSolarTerms(solarTermId):
            "/api/v1/calendar/solar-terms/\(solarTermId)"
        case let .fetchDateRecords(date):
            "/api/v1/calendar/records/\(date)"
        case let .deleteMissionCompletion(completionId):
            "/api/v1/calendar/mission-completions/\(completionId)"
        case let .deleteFreeRecord(recordId):
            "/api/v1/calendar/records/\(recordId)"
        case .completeFreeRecord:
            "/api/v1/calendar/records"
        case let .updateMissionCompletion(completionId, _):
            "/api/v1/calendar/mission-completions/\(completionId)"
        case let .updateFreeRecord(recordId, _):
            "/api/v1/calendar/records/\(recordId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchCurrentSolarTerms, .fetchSolarTerms, .fetchDateRecords:
            .get
        case .deleteMissionCompletion, .deleteFreeRecord:
            .delete
        case .completeFreeRecord:
            .post
        case .updateMissionCompletion, .updateFreeRecord:
            .patch
        }
    }

    var body: Encodable? {
        switch self {
        case let .completeFreeRecord(request):
            request
        case let .updateMissionCompletion(_, request):
            request
        case let .updateFreeRecord(_, request):
            request
        default:
            nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .fetchCurrentSolarTerms,
             .fetchSolarTerms,
             .fetchDateRecords,
             .deleteMissionCompletion,
             .deleteFreeRecord,
             .completeFreeRecord,
             .updateMissionCompletion,
             .updateFreeRecord:
            return true
        }
    }
}
