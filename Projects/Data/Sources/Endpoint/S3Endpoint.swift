//
//  S3Endpoint.swift
//  Data
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

enum S3Endpoint: APIEndpoint {
    case presignedUrl(fileName: String, contentType: String)

    var path: String {
        switch self {
        case .presignedUrl:
            "/api/v1/s3/presigned-url"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .presignedUrl: .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .presignedUrl(fileName, contentType):
            [
                URLQueryItem(name: "fileName", value: fileName),
                URLQueryItem(name: "contentType", value: contentType)
            ]
        }
    }
}
