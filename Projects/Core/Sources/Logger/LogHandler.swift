//
//  LogHandler.swift
//  Core
//
//  Created by Claude on 5/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public protocol LogHandler: Sendable {
    var minimumLevel: LogLevel { get }

    func log(
        level: LogLevel,
        message: String?,
        metadata: MetaData?,
        file: String,
        function: String,
        line: UInt
    )
}
