//
//  SeasonRecord.swift
//  Domain
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//
import Foundation

public struct SeasonRecord: Equatable {
    public var solarTermName: String
    public var photoURL: [URL]
    public var recordCount: Int

    public init(solarTermName: String, photoURL: [URL], recordCount: Int) {
        self.solarTermName = solarTermName
        self.photoURL = photoURL
        self.recordCount = recordCount
    }
}

public extension SeasonRecord {
    static let mock = SeasonRecord(
        solarTermName: "하지",
        photoURL: [
            URL(string: "https://picsum.photos/seed/a/300/300")!,
            URL(string: "https://picsum.photos/seed/b/300/300")!,
            URL(string: "https://picsum.photos/seed/c/300/300")!
        ],
        recordCount: 12
    )
}
