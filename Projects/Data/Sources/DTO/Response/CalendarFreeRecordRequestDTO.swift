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

// MARK: - 기록 수정 요청

struct CalendarRecordUpdateRequestDTO: Encodable {
    let objectKey: String?
    let memo: String?

    enum CodingKeys: String, CodingKey {
        case objectKey
        case memo
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let objectKey {
            try container.encode(objectKey, forKey: .objectKey)
        } else {
            try container.encodeNil(forKey: .objectKey)
        }
        try container.encodeIfPresent(memo, forKey: .memo)
    }
}

// MARK: - 자유 기록 추가 응답

struct CalendarFreeRecordResponseDTO: Decodable {
    let recordId: Int
}
