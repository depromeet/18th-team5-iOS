//
//  ExampleRepositoryImpl.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Foundation

/// Repository 구현체 예시 - CRUD 전체 구현
public final class ExampleRepositoryImpl: ExampleRepository {
    private let client: NetworkClient

    public init() {
        self.client = .shared
    }

    init(client: NetworkClient) {
        self.client = client
    }

    public func fetchItems() async throws -> [ExampleItem] {
        let dtos: [ExampleItemResponseDTO] = try await client.request(
            ExampleEndpoint.fetchItems
        )
        return dtos.map { $0.toDomain() }
    }

    public func fetchDetail(id: Int) async throws -> ExampleDetail {
        let dto: ExampleDetailResponseDTO = try await client.request(
            ExampleEndpoint.fetchDetail(id: id)
        )
        return dto.toDomain()
    }

    public func createItem(
        title: String,
        content: String,
        category: ExampleDetail.Category
    ) async throws -> ExampleDetail {
        let requestDTO = CreateExampleRequestDTO(
            title: title,
            content: content,
            category: category.rawValue
        )
        let dto: ExampleDetailResponseDTO = try await client.request(
            ExampleEndpoint.createItem(body: requestDTO)
        )
        return dto.toDomain()
    }

    public func updateItem(id: Int, title: String, isCompleted: Bool) async throws -> ExampleItem {
        let requestDTO = UpdateExampleRequestDTO(
            title: title,
            isCompleted: isCompleted
        )
        let dto: ExampleItemResponseDTO = try await client.request(
            ExampleEndpoint.updateItem(id: id, body: requestDTO)
        )
        return dto.toDomain()
    }

    public func deleteItem(id: Int) async throws {
        let _: EmptyResponse = try await client.request(
            ExampleEndpoint.deleteItem(id: id)
        )
    }
}

/// DELETE 등 빈 응답을 처리하기 위한 타입
struct EmptyResponse: Decodable {}
