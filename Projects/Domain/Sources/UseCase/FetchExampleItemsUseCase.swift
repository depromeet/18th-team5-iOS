//
//  FetchExampleItemsUseCase.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct FetchExampleItemsUseCase: Sendable {
    public var run: @Sendable () async throws -> [ExampleItem]
}

public extension FetchExampleItemsUseCase {
    func execute() async throws -> [ExampleItem] {
        try await run()
    }
}

// MARK: - DependencyKey

extension FetchExampleItemsUseCase: DependencyKey {
    public static let liveValue = FetchExampleItemsUseCase(
        run: {
            @Dependency(\.exampleRepository) var repository
            return try await repository.fetchItems()
        }
    )
}

public extension DependencyValues {
    var fetchExampleItemsUseCase: FetchExampleItemsUseCase {
        get { self[FetchExampleItemsUseCase.self] }
        set { self[FetchExampleItemsUseCase.self] = newValue }
    }
}
