//
//  ExampleRepository.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

/// Protocol 대신 struct-of-closures 패턴으로 개별 엔드포인트 단위의 테스트 오버라이드 지원
@DependencyClient
public struct ExampleRepository: Sendable {
    public var fetchItems: @Sendable () async throws -> [ExampleItem] = { [] }
    public var fetchDetail: @Sendable (_ id: Int) async throws -> ExampleDetail
    public var createItem: @Sendable (
        _ title: String,
        _ content: String,
        _ category: ExampleDetail.Category
    ) async throws -> ExampleDetail
    public var updateItem: @Sendable (_ id: Int, _ title: String, _ isCompleted: Bool) async throws -> ExampleItem
    public var deleteItem: @Sendable (_ id: Int) async throws -> Void
}

// MARK: - TestDependencyKey

extension ExampleRepository: TestDependencyKey {
    public static let testValue = ExampleRepository()
}

public extension DependencyValues {
    var exampleRepository: ExampleRepository {
        get { self[ExampleRepository.self] }
        set { self[ExampleRepository.self] = newValue }
    }
}
