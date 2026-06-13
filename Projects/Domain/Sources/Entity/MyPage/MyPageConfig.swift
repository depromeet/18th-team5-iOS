//
//  MyPageConfig.swift
//  Domain
//
//  Created by 이정원 on 6/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct MyPageConfig: Equatable {
    public let contactUsURL: URL?
    public let latestAppVersion: AppVersion?
    public let isDevModeEnabled: Bool

    public init(
        contactUsURL: URL?,
        latestAppVersion: AppVersion?,
        isDevModeEnabled: Bool
    ) {
        self.contactUsURL = contactUsURL
        self.latestAppVersion = latestAppVersion
        self.isDevModeEnabled = isDevModeEnabled
    }
}
