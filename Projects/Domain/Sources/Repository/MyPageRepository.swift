//
//  MyPageRepository.swift
//  Domain
//
//  Created by 이정원 on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros

@DependencyClient
public struct MyPageRepository: Sendable {
    public var fetchAnnouncements: @Sendable () async throws -> [Announcement]
    public var fetchAnnouncement: @Sendable (Int) async throws -> Announcement?
    public var fetchPrivacyPolicy: @Sendable () async throws -> [DocumentInfo]
    public var fetchTermsOfService: @Sendable () async throws -> [DocumentInfo]
    public var fetchMyPageConfig: @Sendable () async throws -> MyPageConfig
    public var fetchUserID: @Sendable () async throws -> Int?
    public var fetchUserType: @Sendable () async throws -> UserType?
    public var resetUserData: @Sendable () async throws -> Void
}

extension MyPageRepository: TestDependencyKey {
    public static let testValue = MyPageRepository()
}

public extension DependencyValues {
    var myPageRepository: MyPageRepository {
        get { self[MyPageRepository.self] }
        set { self[MyPageRepository.self] = newValue }
    }
}
