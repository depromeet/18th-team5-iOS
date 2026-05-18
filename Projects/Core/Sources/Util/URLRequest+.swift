//
//  URLRequest+.swift
//  Core
//
//  Created by 이정원 on 5/15/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public extension URLRequest {
    var curlString: String {
        var message = ""

        if let urlString = url?.absoluteString {
            message += "curl '\(urlString)'"
        }

        if let httpMethod {
            message += " \\\n-X \(httpMethod)"
        }

        if let allHTTPHeaderFields {
            for (key, value) in allHTTPHeaderFields {
                message += " \\\n-H '\(key): \(value)'"
            }
        }

        if let body = httpBody?.jsonString {
            message += " \\\n-d '\(body)'"
        }

        return message
    }
}
