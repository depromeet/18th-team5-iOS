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
    public var fetchItems: @Sendable () async throws -> [ExampleItem]
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

public extension ExampleRepository {
    static let previewValue = ExampleRepository(
        fetchItems: {
            [
                ExampleItem(id: 1, title: "TCA 공부하기", isCompleted: true),
                ExampleItem(id: 2, title: "swift-dependencies 적용", isCompleted: false),
                ExampleItem(id: 3, title: "프로젝트 문서 정리", isCompleted: true),
                ExampleItem(id: 4, title: "오래된 코드 삭제", isCompleted: false)
            ]
        },
        fetchDetail: { id in
            let mockDetails: [Int: ExampleDetail] = [
                1: ExampleDetail(
                    id: 1,
                    title: "TCA 공부하기",
                    content: "The Composable Architecture 공식 문서를 읽고 예제를 따라해본다.",
                    category: .important,
                    tags: ["TCA", "iOS", "SwiftUI"],
                    imageURL: nil,
                    createdAt: Date()
                ),
                2: ExampleDetail(
                    id: 2,
                    title: "swift-dependencies 적용",
                    content: "@DependencyClient를 활용한 의존성 주입 패턴 적용.",
                    category: .important,
                    tags: ["DI", "Testing"],
                    imageURL: nil,
                    createdAt: Date().addingTimeInterval(-3600)
                ),
                3: ExampleDetail(
                    id: 3,
                    title: "프로젝트 문서 정리",
                    content: "README와 아키텍처 문서를 최신 상태로 업데이트한다.",
                    category: .general,
                    tags: ["문서", "정리"],
                    imageURL: nil,
                    createdAt: Date().addingTimeInterval(-7200)
                ),
                4: ExampleDetail(
                    id: 4,
                    title: "오래된 코드 삭제",
                    content: "사용하지 않는 UseCase 레이어 코드를 제거한다.",
                    category: .archived,
                    tags: ["리팩토링"],
                    imageURL: nil,
                    createdAt: Date().addingTimeInterval(-86400)
                )
            ]
            guard let detail = mockDetails[id] else {
                throw DomainError.notFound
            }
            return detail
        },
        createItem: { title, content, category in
            ExampleDetail(
                id: Int.random(in: 100 ... 999),
                title: title,
                content: content,
                category: category,
                tags: [],
                imageURL: nil,
                createdAt: Date()
            )
        },
        updateItem: { id, title, isCompleted in
            ExampleItem(id: id, title: title, isCompleted: isCompleted)
        },
        deleteItem: { _ in }
    )
}
