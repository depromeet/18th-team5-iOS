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

    public init(client: NetworkClient = .shared) {
        self.client = client
    }

    public func fetchItems() async throws -> [ExampleItem] {
        do {
            let dtos: [ExampleItemResponseDTO] = try await client.request(
                ExampleEndpoint.fetchItems
            )
            return dtos.map { $0.toDomain() }
        } catch {
            throw error.toDomainError()
        }
    }

    public func fetchDetail(id: Int) async throws -> ExampleDetail {
        do {
            let dto: ExampleDetailResponseDTO = try await client.request(
                ExampleEndpoint.fetchDetail(id: id)
            )
            return dto.toDomain()
        } catch {
            throw error.toDomainError()
        }
    }

    public func createItem(
        title: String,
        content: String,
        category: ExampleDetail.Category
    ) async throws -> ExampleDetail {
        do {
            let requestDTO = CreateExampleRequestDTO(
                title: title,
                content: content,
                category: category.rawValue
            )
            let dto: ExampleDetailResponseDTO = try await client.request(
                ExampleEndpoint.createItem(body: requestDTO)
            )
            return dto.toDomain()
        } catch {
            throw error.toDomainError()
        }
    }

    public func updateItem(id: Int, title: String, isCompleted: Bool) async throws -> ExampleItem {
        do {
            let requestDTO = UpdateExampleRequestDTO(
                title: title,
                isCompleted: isCompleted
            )
            let dto: ExampleItemResponseDTO = try await client.request(
                ExampleEndpoint.updateItem(id: id, body: requestDTO)
            )
            return dto.toDomain()
        } catch {
            throw error.toDomainError()
        }
    }

    public func deleteItem(id: Int) async throws {
        do {
            try await client.requestEmpty(
                ExampleEndpoint.deleteItem(id: id)
            )
        } catch {
            throw error.toDomainError()
        }
    }
}

// MARK: - NetworkError → DomainError 매핑

private extension Error {
    func toDomainError() -> DomainError {
        guard let networkError = self as? NetworkError else {
            return .unknown(localizedDescription)
        }
        switch networkError {
        case .invalidURL:
            return .invalidRequest
        case let .requestFailed(statusCode):
            return .serverError(statusCode: statusCode)
        case .decodingFailed:
            return .decodingFailed
        case .networkUnavailable:
            return .networkUnavailable
        case let .unknown(message):
            return .unknown(message)
        }
    }
}
