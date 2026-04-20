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

// MARK: - DependencyKey

extension ExampleRepository: @retroactive DependencyKey {
    public static let liveValue: ExampleRepository = ExampleRepositoryImpl.live()
}

// MARK: - liveValue

public enum ExampleRepositoryImpl {
    static func live() -> ExampleRepository {
        ExampleRepository(
            fetchItems: {
                // 클로저 내부에서 resolve해야 live context 유지
                @Dependency(\.networkClient) var client
                do {
                    let dtos: [ExampleItemResponseDTO] = try await client.request(
                        ExampleEndpoint.fetchItems
                    )
                    return dtos.map { $0.toDomain() }
                } catch {
                    throw error.toDomainError()
                }
            },
            fetchDetail: { id in
                @Dependency(\.networkClient) var client
                do {
                    let dto: ExampleDetailResponseDTO = try await client.request(
                        ExampleEndpoint.fetchDetail(id: id)
                    )
                    return try dto.toDomain()
                } catch {
                    throw error.toDomainError()
                }
            },
            createItem: { title, content, category in
                @Dependency(\.networkClient) var client
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
            },
            updateItem: { id, title, isCompleted in
                @Dependency(\.networkClient) var client
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
            },
            deleteItem: { id in
                @Dependency(\.networkClient) var client
                do {
                    try await client.requestEmpty(
                        ExampleEndpoint.deleteItem(id: id)
                    )
                } catch {
                    throw error.toDomainError()
                }
            }
        )
    }
}

// MARK: - NetworkError -> DomainError 매핑

private extension Error {
    func toDomainError() -> DomainError {
        if self is DTOMappingError {
            return .dataCorrupted
        }
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
