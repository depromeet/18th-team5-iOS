//
//  CreateExampleItemUseCase.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct CreateExampleItemUseCase: Sendable {
    public var run: @Sendable (String, String, ExampleDetail.Category) async throws -> ExampleDetail
}

public extension CreateExampleItemUseCase {
    func execute(
        title: String,
        content: String,
        category: ExampleDetail.Category
    ) async throws -> ExampleDetail {
        try await run(title, content, category)
    }
}

// MARK: - DependencyKey

extension CreateExampleItemUseCase: DependencyKey {
    public static let liveValue = CreateExampleItemUseCase(
        run: { title, content, category in
            @Dependency(\.exampleRepository) var repository
            return try await repository.createItem(
                title: title, content: content, category: category
            )
        }
    )
}

public extension DependencyValues {
    var createExampleItemUseCase: CreateExampleItemUseCase {
        get { self[CreateExampleItemUseCase.self] }
        set { self[CreateExampleItemUseCase.self] = newValue }
    }
}
