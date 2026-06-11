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
        @Dependency(\.networkClient) var networkClient
        let storage = Storage.storage()
        let maxSize: Int64 = 64 * 1024 // max 64KB

        let remoteConfigSettings = RemoteConfigSettings()
        remoteConfigSettings.minimumFetchInterval = 0
        remoteConfigSettings.fetchTimeout = 10

        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = remoteConfigSettings

        return MyPageRepository(
            fetchAnnouncements: {
                let endpoint = AnnouncementEndpoint.fetchAnnouncements
                let response: [AnnouncementResponseDTO]? = try await networkClient.request(endpoint)
                return response?.compactMap(\.toDomain) ?? []
            },
            fetchAnnouncement: { id in
                let endpoint = AnnouncementEndpoint.fetchAnnouncement(id)
                let response: AnnouncementResponseDTO? = try await networkClient.request(endpoint)
                return response?.toDomain
            },
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
            fetchMyPageConfig: {
                try await remoteConfig.fetchAndActivate()
                let contactUsURL = remoteConfig["contactUsURL"].stringValue
                let versionString = remoteConfig["latestAppVersion"].stringValue

                return .init(
                    contactUsURL: URL(string: contactUsURL),
                    latestAppVersion: AppVersion(version: versionString)
                )
            }
        )
    }
}
