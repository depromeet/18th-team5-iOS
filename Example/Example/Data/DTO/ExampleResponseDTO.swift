//
//  ExampleResponseDTO.swift
//  Data
//
//  Created by 진준호 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

struct ExampleItemResponseDTO: Decodable {
    let id: Int
    let title: String
    let isCompleted: Bool
}

struct ExampleDetailResponseDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let category: String
    let tags: [String]
    let imageUrl: String?
    let createdAt: String
}
