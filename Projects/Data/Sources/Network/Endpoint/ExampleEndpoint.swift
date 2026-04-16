//
//  ExampleEndpoint.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

enum ExampleEndpoint: APIEndpoint {
    case fetchItems
    case fetchDetail(id: Int)
    case createItem(body: CreateExampleRequestDTO)
    case updateItem(id: Int, body: UpdateExampleRequestDTO)
    case deleteItem(id: Int)

    var path: String {
        switch self {
        case .fetchItems:
            return "/examples"
        case let .fetchDetail(id):
            return "/examples/\(id)"
        case .createItem:
            return "/examples"
        case let .updateItem(id, _):
            return "/examples/\(id)"
        case let .deleteItem(id):
            return "/examples/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchItems, .fetchDetail:
            return .get
        case .createItem:
            return .post
        case .updateItem:
            return .put
        case .deleteItem:
            return .delete
        }
    }

    func encodedBodyData() throws -> Data? {
        switch self {
        case let .createItem(body):
            return try JSONEncoder().encode(body)
        case let .updateItem(_, body):
            return try JSONEncoder().encode(body)
        default:
            return nil
        }
    }
}
