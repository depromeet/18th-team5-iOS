//
//  Logger+Extension.swift
//  Core
//
//  Created by 진준호 on 4/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation
import os

public extension Logger {
    static let auth = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.peaktime",
        category: "Auth"
    )
}
