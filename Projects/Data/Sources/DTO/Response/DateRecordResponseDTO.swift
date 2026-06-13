//
//  DateRecordResponseDTO.swift
//  Data
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

// MARK: - 날짜별 기록 조회 응답 (배열 result)

struct DateRecordResponseDTO: Decodable {
    /// 각 레코드의 PK (`FREE` → `user_record` PK, 나머지 → `user_mission_completion` PK)
    let id: Int
    /// 기록 타입 (DAILY / RECOMMENDED / SELECTED / FREE)
    let cardType: String
    /// 미션 제목 (FREE 타입이면 null)
    let missionTitle: String?
    /// 이미지 presigned URL (이미지 없으면 null)
    let presignedImageUrl: String?
    let memo: String?
    /// 기록 시각 (ISO 8601)
    let recordedAt: String
}
