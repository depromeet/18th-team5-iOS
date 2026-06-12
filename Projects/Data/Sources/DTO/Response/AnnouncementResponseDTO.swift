//
//  AnnouncementResponseDTO.swift
//  Data
//
//  Created by 이정원 on 6/10/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

struct AnnouncementResponseDTO: Decodable {
    let id: Int?
    let title: String?
    let content: String?
    let createdAt: String?
}

extension AnnouncementResponseDTO {
    var toDomain: Announcement? {
        guard let id,
              let title,
              let createdAt
        else {
            return nil
        }

        let date = ISO8601DateFormatter().date(from: createdAt)
        guard let date else { return nil }

        return .init(
            id: id,
            title: title,
            content: content,
            date: date
        )
    }
}
