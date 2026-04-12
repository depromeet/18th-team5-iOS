//
//  AppVersion.swift
//  Domain
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct AppVersion: Comparable {
    public let major: Int
    public let minor: Int
    public let patch: Int
}

public extension AppVersion {
    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }
}

public extension AppVersion {
    static var current: AppVersion? {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else {
            assertionFailure("번들 정보를 획득할 수 없습니다.")
            return nil
        }
        let splited = version.split(separator: ".")

        guard let major = Int(splited[0]),
              let minor = Int(splited[1]),
              let patch = Int(splited[2])
        else {
            assertionFailure("번들 버전 문자열 형식이 잘못됬습니다.")
            return nil
        }
        return AppVersion(major: major, minor: minor, patch: patch)
    }
}
