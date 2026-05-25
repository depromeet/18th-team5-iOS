//
//  MissionDTO.swift
//  Data
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

// MARK: - Presigned URL 응답

struct PresignedUrlResultDTO: Decodable {
    let presignedUrl: String
    let objectKey: String
}

// MARK: - 미션 완료 요청

struct MissionCompleteRequestDTO: Encodable {
    let missionType: String
    let solarTermId: Int
    let objectKey: String
    let memo: String?
}

// MARK: - 미션 완료 응답

struct MissionCompleteResultDTO: Decodable {
    let completionId: Int
}

// MARK: - 미션 완료 기록 조회 응답

struct MissionCompletionItemDTO: Decodable {
    let completionId: Int
    let missionId: Int
    let missionType: String
    let objectKey: String?
    let presignedImageUrl: String?
    let memo: String?
    let completedAt: String
}
