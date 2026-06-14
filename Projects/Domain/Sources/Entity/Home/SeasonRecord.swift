//
//  SeasonRecord.swift
//  Domain
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//
import Foundation

public struct RecentRecord: Equatable {
    public let imageURL: URL
    public let recordedAt: String

    public init(imageURL: URL, recordedAt: String) {
        self.imageURL = imageURL
        self.recordedAt = recordedAt
    }
}

public struct SeasonRecord: Equatable {
    public var solarTermName: String
    public var recentRecords: [RecentRecord]
    public var recordCount: Int

    public init(solarTermName: String, recentRecords: [RecentRecord], recordCount: Int) {
        self.solarTermName = solarTermName
        self.recentRecords = recentRecords
        self.recordCount = recordCount
    }

    public var photoURL: [URL] {
        recentRecords.map(\.imageURL)
    }
}

public extension SeasonRecord {
    static let mock = SeasonRecord(
        solarTermName: "하지",
        recentRecords: [
            RecentRecord(imageURL: URL(string: "https://picsum.photos/seed/a/300/300")!, recordedAt: "2026-06-14"),
            RecentRecord(imageURL: URL(string: "https://picsum.photos/seed/b/300/300")!, recordedAt: "2026-06-13"),
            RecentRecord(imageURL: URL(string: "https://picsum.photos/seed/c/300/300")!, recordedAt: "2026-06-12")
        ],
        recordCount: 12
    )
}
