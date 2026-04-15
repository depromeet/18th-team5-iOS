//
//  ExampleEndpoint.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Alamofire
import Foundation

/// Endpoint 예시 - GET, POST, PUT, DELETE 전체 HTTP 메서드 포함
enum ExampleEndpoint: APIEndpoint {
    /// 목록 조회
    case fetchItems
    /// 상세 조회
    case fetchDetail(id: Int)
    /// 생성
    case createItem(body: CreateExampleRequestDTO)
    /// 수정
    case updateItem(id: Int, body: UpdateExampleRequestDTO)
    /// 삭제
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

    var parameters: Parameters? {
        switch self {
        case let .createItem(body):
            return body.toDictionary()
        case let .updateItem(_, body):
            return body.toDictionary()
        default:
            return nil
        }
    }
}

// MARK: - Encodable을 Parameters(Dictionary)로 변환하는 헬퍼

private extension Encodable {
    func toDictionary() -> Parameters? {
        guard let data = try? JSONEncoder().encode(self),
              let dict = try? JSONSerialization.jsonObject(with: data) as? Parameters else {
            return nil
        }
        return dict
    }
}
