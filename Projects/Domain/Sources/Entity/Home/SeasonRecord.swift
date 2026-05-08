//
//  SeasonRecord.swift
//  Domain
//
//  Created by 송민교 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//
import Foundation

public struct SeasonRecord: Equatable {
    public var photoURL: [URL]
    public var recordCount: Int

    public init(photoURL: [URL], recordCount: Int) {
        self.photoURL = photoURL
        self.recordCount = recordCount
    }
}

public extension SeasonRecord {
    static let mock = SeasonRecord(photoURL: [
        URL(string: "https://picsum.photos/seed/a/300/300")!,
        URL(string: "https://picsum.photos/seed/b/300/300")!,
        URL(string: "https://picsum.photos/seed/c/300/300")!
    ], recordCount: 5)
}
