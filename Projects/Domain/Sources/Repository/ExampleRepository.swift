//
//  ExampleRepository.swift
//  Domain
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

/// Repository 프로토콜 예시 - CRUD 전체 케이스 포함
public protocol ExampleRepository {
    /// 목록 조회 (GET)
    func fetchItems() async throws -> [ExampleItem]

    /// 단건 상세 조회 (GET)
    func fetchDetail(id: Int) async throws -> ExampleDetail

    /// 생성 (POST)
    func createItem(title: String, content: String, category: ExampleDetail.Category) async throws -> ExampleDetail

    /// 수정 (PUT)
    func updateItem(id: Int, title: String, isCompleted: Bool) async throws -> ExampleItem

    /// 삭제 (DELETE)
    func deleteItem(id: Int) async throws
}
