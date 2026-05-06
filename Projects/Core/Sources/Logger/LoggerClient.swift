//
//  LoggerClient.swift
//  Core
//
//  Created by Claude on 5/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import DependenciesMacros

@DependencyClient
public struct LoggerClient: Sendable {
    public var log: @Sendable (
        _ level: LogLevel,
        _ message: String?,
        _ metadata: MetaData?,
        _ file: String,
        _ function: String,
        _ line: UInt
    ) -> Void
}

// MARK: - Convenience Methods

public extension LoggerClient {
    func debug(
        _ message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.debug, message, metadata, file, function, line)
    }

    func info(
        _ message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.info, message, metadata, file, function, line)
    }

    func warning(
        _ message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.warning, message, metadata, file, function, line)
    }

    func error(
        _ message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.error, message, metadata, file, function, line)
    }

    func fatal(
        _ message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.fatal, message, metadata, file, function, line)
    }
}

// MARK: - DependencyKey

extension LoggerClient: DependencyKey {
    public static let liveValue: LoggerClient = {
        let logger = Logger(handlers: [DebugLogHandler()])
        return LoggerClient { level, message, metadata, file, function, line in
            logger.log(level: level, message: message, metadata: metadata, file: file, function: function, line: line)
        }
    }()

    public static let previewValue: LoggerClient = liveValue
    public static let testValue: LoggerClient = liveValue
}

public extension DependencyValues {
    var loggerClient: LoggerClient {
        get { self[LoggerClient.self] }
        set { self[LoggerClient.self] = newValue }
    }
}
