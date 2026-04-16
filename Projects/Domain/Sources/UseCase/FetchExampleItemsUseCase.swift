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
    public var execute: @Sendable () async throws -> [ExampleItem] = { [] }
}

// MARK: - TestDependencyKey

extension FetchExampleItemsUseCase: TestDependencyKey {
    public static let testValue = FetchExampleItemsUseCase()

    public static let previewValue = FetchExampleItemsUseCase(
        execute: {
            [
                ExampleItem(id: 1, title: "Preview 아이템 1", isCompleted: false),
                ExampleItem(id: 2, title: "Preview 아이템 2", isCompleted: true)
            ]
        }
    )
}

public extension DependencyValues {
    var fetchExampleItemsUseCase: FetchExampleItemsUseCase {
        get { self[FetchExampleItemsUseCase.self] }
        set { self[FetchExampleItemsUseCase.self] = newValue }
    }
}
