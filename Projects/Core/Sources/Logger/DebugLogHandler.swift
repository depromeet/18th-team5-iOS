//
//  DebugLogHandler.swift
//  Core
//
//  Created by Claude on 5/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct DebugLogHandler: LogHandler {
    public let minimumLevel: LogLevel

    public init(minimumLevel: LogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }

    public func log(
        level: LogLevel,
        message: String?,
        metadata: MetaData?,
        file: String,
        function: String,
        line: UInt
    ) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = Date()
        var output = "[\(timestamp)] [\(level)] \(fileName):\(line) \(function)"
        if let message { output += " - \(message)" }
        if let metadata { output += " | \(metadata)" }
        print(output)
    }
}
