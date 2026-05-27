//
//  Encodable+.swift
//  Core
//
//  Created by 이정원 on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public extension Encodable {
    var queryItems: [URLQueryItem]? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let dictionary = jsonObject as? [String: String] else {
            return nil
        }

        return dictionary.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
    }
}
