//
//  CalendarResponseDTO.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

// MARK: - 절기 캘린더 조회 응답 (현재 절기 조회 / 페이지네이션 공통)

struct CalendarSolarTermsResponseDTO: Decodable {
    let solarTerms: [CalendarSolarTermDTO]
    /// 이전 페이지 절기 ID (첫 번째 절기면 null)
    let prevSolarTermId: Int?
    /// 다음 페이지 절기 ID (마지막 절기면 null)
    let nextSolarTermId: Int?
}

struct CalendarSolarTermDTO: Decodable {
    let solarTermId: Int
    let name: String
    /// 절기 시작일 (yyyy-MM-dd)
    let startDate: String
    /// 절기 종료일 (yyyy-MM-dd)
    let endDate: String
    let dates: [CalendarSolarTermDateDTO]
}

struct CalendarSolarTermDateDTO: Decodable {
    /// 날짜 (yyyy-MM-dd)
    let date: String
    /// 대표 기록 이미지 presigned URL (기록 없으면 null)
    let thumbnailUrl: String?
}
