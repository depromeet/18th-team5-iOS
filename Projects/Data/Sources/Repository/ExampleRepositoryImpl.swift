//
//  ExampleRepositoryImpl.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Foundation

public final class ExampleRepositoryImpl {
    @Dependency(\.networkClient) private var client
}

// MARK: - liveValue

public extension ExampleRepositoryImpl {
    static func live() -> ExampleRepository {
        let impl = ExampleRepositoryImpl()
        return ExampleRepository(
            fetchItems: { try await impl.fetchItems() },
            fetchDetail: { try await impl.fetchDetail(id: $0) },
            createItem: { try await impl.createItem(title: $0, content: $1, category: $2) },
            updateItem: { try await impl.updateItem(id: $0, title: $1, isCompleted: $2) },
            deleteItem: { try await impl.deleteItem(id: $0) }
        )
    }
}

// MARK: - 내부 구현

private extension ExampleRepositoryImpl {
    func fetchItems() async throws -> [ExampleItem] {
        do {
            let dtos: [ExampleItemResponseDTO] = try await client.request(
                ExampleEndpoint.fetchItems
            )
            return dtos.map { $0.toDomain() }
        } catch {
            throw error.toDomainError()
        }
    }

    func fetchDetail(id: Int) async throws -> ExampleDetail {
        do {
            let dto: ExampleDetailResponseDTO = try await client.request(
                ExampleEndpoint.fetchDetail(id: id)
            )
            return try dto.toDomain()
        } catch {
            throw error.toDomainError()
        }
    }

    func createItem(
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
            return try dto.toDomain()
        } catch {
            throw error.toDomainError()
        }
    }

    func updateItem(id: Int, title: String, isCompleted: Bool) async throws -> ExampleItem {
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

    func deleteItem(id: Int) async throws {
        do {
            try await client.requestEmpty(
                ExampleEndpoint.deleteItem(id: id)
            )
        } catch {
            throw error.toDomainError()
        }
    }
}

// MARK: - NetworkError -> DomainError 매핑

private extension Error {
    func toDomainError() -> DomainError {
        guard let networkError = self as? NetworkError else {
            return .unknown(localizedDescription)
        }
        switch networkError {
        case .invalidURL, .encodingFailed:
            return .invalidRequest(nil)
        case let .requestFailed(statusCode):
            switch statusCode {
            case 400, 422:
                return .invalidRequest(nil)
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500 ... 599:
                return .serverError
            default:
                return .unknown("HTTP \(statusCode)")
            }
        case .decodingFailed:
            return .dataCorrupted
        case .networkUnavailable:
            return .serviceUnavailable
        case let .unknown(message):
            return .unknown(message)
        }
    }
}
