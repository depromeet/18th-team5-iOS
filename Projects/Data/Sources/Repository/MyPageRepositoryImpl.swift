//
//  MyPageRepositoryImpl.swift
//  Data
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import FirebaseStorage
import Foundation

extension MyPageRepository: @retroactive DependencyKey {
    public static let liveValue: MyPageRepository = MyPageRepositoryImpl.live()
}

enum MyPageRepositoryImpl {
    static func live() -> MyPageRepository {
        let storage = Storage.storage()

        return MyPageRepository(
            fetchPrivacyPolicy: {
                let reference = storage.reference().child("privacy_policy.json")
                let data = try await reference.data(maxSize: 64 * 1024) // max 64KB
                let response = try JSONDecoder().decode([PrivacyPolicyResponseDTO].self, from: data)
                return response.compactMap(\.toDoamin)
            }
        )
    }
}
