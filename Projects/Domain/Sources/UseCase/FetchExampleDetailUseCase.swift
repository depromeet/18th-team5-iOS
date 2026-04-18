//
//  FetchExampleDetailUseCase.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct FetchExampleDetailUseCase: Sendable {
    public var run: @Sendable (Int) async throws -> ExampleDetail
}

public extension FetchExampleDetailUseCase {
    func execute(id: Int) async throws -> ExampleDetail {
        try await run(id)
    }
}

// MARK: - DependencyKey

extension FetchExampleDetailUseCase: DependencyKey {
    public static let liveValue = FetchExampleDetailUseCase(
        run: { id in
            @Dependency(\.exampleRepository) var repository
            return try await repository.fetchDetail(id: id)
        }
    )
}

public extension DependencyValues {
    var fetchExampleDetailUseCase: FetchExampleDetailUseCase {
        get { self[FetchExampleDetailUseCase.self] }
        set { self[FetchExampleDetailUseCase.self] = newValue }
    }
}
