//
//  DebugLogHandler.swift
//  Core
//
//  Created by Claude on 5/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation
import os

public struct DebugLogHandler: LogHandler {
    public let minimumLevel: LogLevel
    private let logger: os.Logger

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "HH:mm:ss"
        return df
    }()

    public init(
        minimumLevel: LogLevel = .debug,
        subsystem: String = Bundle.main.bundleIdentifier ?? "Core",
        category: String = "Debug"
    ) {
        self.minimumLevel = minimumLevel
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func log(
        level: LogLevel,
        message: String?,
        metadata: MetaData?,
        file: String,
        function: String,
        line: UInt
    ) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: .now)
        var output = "[\(timestamp)] [\(level)] \(fileName):\(line) \(function)"
        if let message { output += " - \(message)" }
        if let metadata { output += " | \(metadata)" }

        switch level {
        case .debug:
            logger.debug("\(output, privacy: .public)")
        case .info:
            logger.info("\(output, privacy: .public)")
        case .warning:
            logger.warning("\(output, privacy: .public)")
        case .error:
            logger.error("\(output, privacy: .public)")
        case .fatal:
            logger.critical("\(output, privacy: .public)")
        }
        #endif
    }
}
