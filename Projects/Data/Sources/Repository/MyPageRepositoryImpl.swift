//
//  MyPageRepositoryImpl.swift
//  Data
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import FirebaseRemoteConfig
import FirebaseStorage
import Foundation

extension MyPageRepository: @retroactive DependencyKey {
    public static let liveValue: MyPageRepository = MyPageRepositoryImpl.live()
}

enum MyPageRepositoryImpl {
    static func live() -> MyPageRepository {
        let storage = Storage.storage()
        let maxSize: Int64 = 64 * 1024 // max 64KB

        return MyPageRepository(
            fetchPrivacyPolicy: {
                let reference = storage.reference().child("privacy_policy.json")
                let data = try await reference.data(maxSize: maxSize)
                let response = try JSONDecoder().decode([DocumentResponseDTO].self, from: data)
                return response.compactMap(\.toDomain)
            },
            fetchTermsOfService: {
                let reference = storage.reference().child("terms_of_service.json")
                let data = try await reference.data(maxSize: maxSize)
                let response = try JSONDecoder().decode([DocumentResponseDTO].self, from: data)
                return response.compactMap(\.toDomain)
            },
            fetchContactUsURL: {
                let settings = RemoteConfigSettings()
                settings.minimumFetchInterval = 0
                settings.fetchTimeout = 10

                let remoteConfig = RemoteConfig.remoteConfig()
                remoteConfig.configSettings = settings

                try await remoteConfig.fetchAndActivate()
                let url = remoteConfig["contactUsURL"].stringValue
                return url.isEmpty ? nil : url
            }
        )
    }
}
