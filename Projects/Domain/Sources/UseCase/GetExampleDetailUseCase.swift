//
//  GetExampleDetailUseCase.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// UseCase 예시 - 파라미터를 받아 단건 조회
public struct GetExampleDetailUseCase {
    private let repository: ExampleRepository

    public init(repository: ExampleRepository) {
        self.repository = repository
    }

    public func execute(id: Int) async throws -> ExampleDetail {
        try await repository.fetchDetail(id: id)
    }
}
