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
    /// 자유 기록 추가
    case completeFreeRecord(CalendarFreeRecordRequestDTO)

    var path: String {
        switch self {
        case .fetchCurrentSolarTerms:
            "/api/v1/calendar/solar-terms"
        case let .fetchSolarTerms(solarTermId):
            "/api/v1/calendar/solar-terms/\(solarTermId)"
        case .completeFreeRecord:
            "/api/v1/calendar/records"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchCurrentSolarTerms, .fetchSolarTerms:
            .get
        case .completeFreeRecord:
            .post
        }
    }

    var body: Encodable? {
        switch self {
        case let .completeFreeRecord(request):
            request
        case .fetchCurrentSolarTerms, .fetchSolarTerms:
            nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .fetchCurrentSolarTerms, .fetchSolarTerms, .completeFreeRecord:
            true
        }
    }
}
