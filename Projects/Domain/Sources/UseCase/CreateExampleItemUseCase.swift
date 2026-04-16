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
    public var execute: @Sendable (_ title: String, _ content: String, _ category: ExampleDetail.Category) async throws
        -> ExampleDetail
}

// MARK: - TestDependencyKey

extension CreateExampleItemUseCase: TestDependencyKey {
    public static let testValue = CreateExampleItemUseCase()

    public static let previewValue = CreateExampleItemUseCase(
        execute: { title, content, category in
            ExampleDetail(
                id: Int.random(in: 100 ... 999),
                title: title,
                content: content,
                category: category,
                tags: [],
                imageURL: nil,
                createdAt: Date()
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
