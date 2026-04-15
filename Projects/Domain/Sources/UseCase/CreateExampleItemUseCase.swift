//
//  CreateExampleItemUseCase.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// UseCase 예시 - 데이터 생성 (POST에 대응)
public struct CreateExampleItemUseCase {
    private let repository: ExampleRepository

    public init(repository: ExampleRepository) {
        self.repository = repository
    }

    public func execute(
        title: String,
        content: String,
        category: ExampleDetail.Category
    ) async throws -> ExampleDetail {
        try await repository.createItem(
            title: title,
            content: content,
            category: category
        )
    }
}
