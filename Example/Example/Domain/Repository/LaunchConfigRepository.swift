//
//  LaunchConfigRepository.swift
//  Domain
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

/// Protocol 대신 struct-of-closures 패턴으로 개별 엔드포인트 단위의 테스트 오버라이드 지원
@DependencyClient
public struct LaunchConfigRepository: Sendable {
    public var fetch: @Sendable () async throws -> LaunchConfig
}

// MARK: - TestDependencyKey

extension LaunchConfigRepository: TestDependencyKey {
    public static let testValue = LaunchConfigRepository()
}

public extension DependencyValues {
    var launchConfigRepository: LaunchConfigRepository {
        get { self[LaunchConfigRepository.self] }
        set { self[LaunchConfigRepository.self] = newValue }
    }
}

public extension LaunchConfigRepository {
    static let previewValue = LaunchConfigRepository(
        fetch: {
            LaunchConfig(
                maintenance: false,
                minimumAppVersion: AppVersion(version: "0.0.0")!
            )
        }
    )
}
