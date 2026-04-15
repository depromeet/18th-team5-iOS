//
//  FetchExampleItemsUseCase.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// UseCase 예시 - 단순 조회 (파라미터 없음)
public struct FetchExampleItemsUseCase {
    private let repository: ExampleRepository

    public init(repository: ExampleRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [ExampleItem] {
        try await repository.fetchItems()
    }
}
