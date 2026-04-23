//
//  CategoryGroup.swift
//  Domain
//
//  Created by 진준호 on 4/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// 카테고리별로 그룹핑된 아이템 목록 (데이터 가공/변환 결과)
public struct CategoryGroup: Equatable, Identifiable {
    public var id: ExampleDetail.Category {
        category
    }

    /// 카테고리
    public let category: ExampleDetail.Category
    /// 해당 카테고리에 속하는 아이템 상세 목록 (createdAt 기준 정렬)
    public let items: [ExampleDetail]
    /// 해당 카테고리 내 완료율 (0.0 ~ 1.0)
    public let completionRate: Double

    public init(
        category: ExampleDetail.Category,
        items: [ExampleDetail],
        completionRate: Double
    ) {
        self.category = category
        self.items = items
        self.completionRate = completionRate
    }
}
