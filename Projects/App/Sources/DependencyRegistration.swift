//
//  DependencyRegistration.swift
//  App
//
//  Created by 진준호 on 4/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Data
import Dependencies
import Domain

// MARK: - Domain(Interface)에서 TestDependencyKey, App에서 DependencyKey를 채택하여 liveValue 등록

extension ExampleRepository: @retroactive DependencyKey {
    public static let liveValue: ExampleRepository = ExampleRepositoryImpl.live()
}

extension FetchExampleItemsUseCase: @retroactive DependencyKey {
    public static let liveValue = FetchExampleItemsUseCase(
        execute: {
            @Dependency(\.exampleRepository) var repository
            return try await repository.fetchItems()
        }
    )
}

extension FetchExampleDetailUseCase: @retroactive DependencyKey {
    public static let liveValue = FetchExampleDetailUseCase(
        execute: {
            @Dependency(\.exampleRepository) var repository
            return try await repository.fetchDetail(id: $0)
        }
    )
}

extension CreateExampleItemUseCase: @retroactive DependencyKey {
    public static let liveValue = CreateExampleItemUseCase(
        execute: {
            @Dependency(\.exampleRepository) var repository
            return try await repository.createItem(title: $0, content: $1, category: $2)
        }
    )
}
