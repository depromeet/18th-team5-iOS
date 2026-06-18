//
//  DateRecordCard.swift
//  Domain
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// 날짜별 기록 조회 시 반환되는 기록 카드 한 장
///
/// - Note: `id`는 `cardType`에 따라 가리키는 테이블이 다릅니다.
///   `.free`이면 `user_record` PK, 나머지는 `user_mission_completion` PK이므로
///   서로 다른 타입 간 `id`가 중복될 수 있습니다. (식별자로 단독 사용 금지)
public struct DateRecordCard: Equatable {
    public let id: Int
    public let cardType: RecordCardType
    /// 미션 ID (`.free` 타입이면 nil)
    public let missionID: Int?
    /// 미션 제목 (`.free` 타입이면 nil)
    public let missionTitle: String?
    /// 미션 설명 (`.free` 타입이면 nil)
    public let missionDescription: String?
    /// 기록 이미지 presigned URL (이미지 없으면 nil)
    public let imageURL: URL?
    public let memo: String?
    /// 기록 시각
    public let recordedAt: Date

    public init(
        id: Int,
        cardType: RecordCardType,
        missionID: Int?,
        missionTitle: String?,
        missionDescription: String?,
        imageURL: URL?,
        memo: String?,
        recordedAt: Date
    ) {
        self.id = id
        self.cardType = cardType
        self.missionID = missionID
        self.missionTitle = missionTitle
        self.missionDescription = missionDescription
        self.imageURL = imageURL
        self.memo = memo
        self.recordedAt = recordedAt
    }
}

/// 날짜별 기록 카드 타입
public enum RecordCardType: CaseIterable {
    /// 오늘의 미션
    case daily
    /// 추천 미션
    case recommended
    /// 선택 미션
    case selected
    /// 자유 기록
    case free

    /// 카드 정렬 순서 (DAILY > RECOMMENDED > SELECTED > FREE)
    public var calendarOrder: Int {
        switch self {
        case .daily: 0
        case .recommended: 1
        case .selected: 2
        case .free: 3
        }
    }
}
