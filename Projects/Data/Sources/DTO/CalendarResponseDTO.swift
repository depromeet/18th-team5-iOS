//  CalendarResponseDTO.swift
//  Data
//
//  Created by 송민교 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

// MARK: - 월별 기록 조회 응답

struct CalendarMonthResponseDTO: Decodable {
    let code: String
    let message: String
    let data: CalendarMonthDataDTO
}

struct CalendarMonthDataDTO: Decodable {
    let year: Int
    let month: Int
    let records: [CalendarRecordResponseDTO]
}

struct CalendarRecordResponseDTO: Decodable {
    let date: String
    let hasRecord: Bool
    let thumbnailImageUrl: String?
}

// MARK: - 날짜별 미션 완료 기록 상세 조회 응답

struct DayDetailResponseWrapperDTO: Decodable {
    let code: String
    let message: String
    let data: DayDetailDataDTO
}

struct DayDetailDataDTO: Decodable {
    let date: String
}
