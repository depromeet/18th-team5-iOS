//
//  Data+.swift
//  Core
//
//  Created by 이정원 on 5/15/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public extension Data {
    var jsonString: String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self)
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
