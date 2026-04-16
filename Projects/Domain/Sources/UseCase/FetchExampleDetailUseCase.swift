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
    public var execute: @Sendable (_ id: Int) async throws -> ExampleDetail
}

// MARK: - TestDependencyKey

extension FetchExampleDetailUseCase: TestDependencyKey {
    public static let testValue = FetchExampleDetailUseCase()

    public static let previewValue = FetchExampleDetailUseCase(
        execute: { id in
            ExampleDetail(
                id: id,
                title: "Preview 상세 아이템",
                content: "Preview에서 보여지는 샘플 콘텐츠입니다.",
                category: .general,
                tags: ["preview"],
                imageURL: nil,
                createdAt: Date()
            )
        }
    )
}

public extension DependencyValues {
    var fetchExampleDetailUseCase: FetchExampleDetailUseCase {
        get { self[FetchExampleDetailUseCase.self] }
        set { self[FetchExampleDetailUseCase.self] = newValue }
    }
}
