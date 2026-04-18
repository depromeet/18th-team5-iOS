//
//  FetchGroupedItemsUseCase.swift
//  Domain
//
//  Created by 진준호 on 4/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct FetchGroupedItemsUseCase: Sendable {
    public var run: @Sendable () async throws -> [CategoryGroup]
}

public extension FetchGroupedItemsUseCase {
    func execute() async throws -> [CategoryGroup] {
        try await run()
    }
}

// MARK: - DependencyKey

extension FetchGroupedItemsUseCase: DependencyKey {
    public static let liveValue = FetchGroupedItemsUseCase(
        run: {
            @Dependency(\.exampleRepository) var repository

            // 1. 전체 목록 조회
            let items = try await repository.fetchItems()

            // 2. 각 아이템의 상세 정보를 병렬로 조회
            let details = try await withThrowingTaskGroup(
                of: ExampleDetail.self,
                returning: [ExampleDetail].self
            ) { group in
                for item in items {
                    group.addTask {
                        try await repository.fetchDetail(id: item.id)
                    }
                }

                var results: [ExampleDetail] = []
                for try await detail in group {
                    results.append(detail)
                }
                return results
            }

            // 3. 완료 여부 조회를 위해 id -> isCompleted 매핑
            let completionMap = Dictionary(
                uniqueKeysWithValues: items.map { ($0.id, $0.isCompleted) }
            )

            // 4. 카테고리별 그룹핑
            let grouped = Dictionary(grouping: details) { $0.category }

            // 5. 각 그룹을 CategoryGroup으로 변환 (createdAt 정렬 + 완료율 계산)
            let categoryOrder: [ExampleDetail.Category] = [.important, .general, .archived]

            return grouped.map { category, groupDetails in
                let sortedDetails = groupDetails.sorted { $0.createdAt > $1.createdAt }
                let groupCompletedCount = groupDetails.filter { completionMap[$0.id] == true }.count
                let groupCompletionRate = groupDetails.isEmpty
                    ? 0.0
                    : Double(groupCompletedCount) / Double(groupDetails.count)

                return CategoryGroup(
                    category: category,
                    items: sortedDetails,
                    completionRate: groupCompletionRate
                )
            }
            .sorted { lhs, rhs in
                let lhsIndex = categoryOrder.firstIndex(of: lhs.category) ?? categoryOrder.count
                let rhsIndex = categoryOrder.firstIndex(of: rhs.category) ?? categoryOrder.count
                return lhsIndex < rhsIndex
            }
        }
    )
}

public extension DependencyValues {
    var fetchGroupedItemsUseCase: FetchGroupedItemsUseCase {
        get { self[FetchGroupedItemsUseCase.self] }
        set { self[FetchGroupedItemsUseCase.self] = newValue }
    }
}
