//
//  CalendarFreeRecordRequestDTO.swift
//  Data
//
//  Created by 진준호 on 6/10/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// MARK: - 자유 기록 추가 요청

struct CalendarFreeRecordRequestDTO: Encodable {
    let recordDate: String
    let objectKey: String
    let memo: String?
}

// MARK: - 자유 기록 추가 응답

struct CalendarFreeRecordResponseDTO: Decodable {
    let recordId: Int
}
