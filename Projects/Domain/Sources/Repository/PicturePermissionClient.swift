//
//  PicturePermissionClient.swift
//  Domain
//
//  Created by 진준호 on 5/23/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros
import Foundation

public enum PicturePermissionKind: Sendable, Equatable {
    case camera
    case photoLibrary
}

public enum PicturePermissionStatus: Sendable, Equatable {
    case notDetermined
    case denied
    case restricted
    case authorized
    case limited
}

@DependencyClient
public struct PicturePermissionClient: Sendable {
    public var status: @Sendable (_ kind: PicturePermissionKind) async -> PicturePermissionStatus = { _ in .notDetermined }
    public var request: @Sendable (_ kind: PicturePermissionKind) async -> Bool = { _ in false }
    public var openSettings: @Sendable () async -> Void
}

// MARK: - TestDependencyKey

extension PicturePermissionClient: TestDependencyKey {
    public static let testValue = PicturePermissionClient()
}

public extension DependencyValues {
    var picturePermissionClient: PicturePermissionClient {
        get { self[PicturePermissionClient.self] }
        set { self[PicturePermissionClient.self] = newValue }
    }
}
