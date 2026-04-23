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
                    throw mapToDomainError(error)
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
                    throw mapToDomainError(error)
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
                    throw mapToDomainError(error)
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
                    throw mapToDomainError(error)
                }
            },
            deleteItem: { id in
                @Dependency(\.networkClient) var client
                do {
                    try await client.requestEmpty(
                        ExampleEndpoint.deleteItem(id: id)
                    )
                } catch {
                    throw mapToDomainError(error)
                }
            }
        )
    }
}

// MARK: - toDomain

extension ExampleItemResponseDTO {
    func toDomain() -> ExampleItem {
        ExampleItem(
            id: id,
            title: title,
            isCompleted: isCompleted
        )
    }
}

extension ExampleDetailResponseDTO {
    private static let iso8601Formatter = ISO8601DateFormatter()

    func toDomain() throws -> ExampleDetail {
        guard let parsedDate = Self.iso8601Formatter.date(from: createdAt) else {
            throw DTOMappingError.invalidDateFormat(createdAt)
        }

        return ExampleDetail(
            id: id,
            title: title,
            content: content,
            category: ExampleDetail.Category(rawValue: category) ?? .general,
            tags: tags,
            imageURL: imageUrl.flatMap { URL(string: $0) },
            createdAt: parsedDate
        )
    }
}
