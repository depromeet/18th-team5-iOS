//  CalendarRecord.swift
//  Domain
//
//  Created by 송민교 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct CalendarRecord: Equatable, Identifiable, Sendable {
    public var id: String {
        dateString
    }

    public let dateString: String // "yyyy-MM-dd"
    public let date: Date
    public let imageURL: URL

    public init(dateString: String, date: Date, imageURL: URL) {
        self.dateString = dateString
        self.date = date
        self.imageURL = imageURL
    }
}
