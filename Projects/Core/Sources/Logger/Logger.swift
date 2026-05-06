//
//  Logger.swift
//  Core
//
//  Created by Claude on 5/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies

public final class Logger: Sendable {
    private let handlers: [LogHandler]

    public init(handlers: [LogHandler] = []) {
        self.handlers = handlers
    }

    public func log(
        level: LogLevel,
        message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        for handler in handlers {
            guard level >= handler.minimumLevel else { continue }
            handler.log(
                level: level,
                message: message,
                metadata: metadata,
                file: file,
                function: function,
                line: line
            )
        }
    }

    public func debug(
        message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .debug,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }

    public func info(
        message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .info,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }

    public func warning(
        message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .warning,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }

    public func error(
        message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .error,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }

    public func fatal(
        message: String? = nil,
        metadata: MetaData? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(
            level: .fatal,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }
}

// MARK: Dependencies

public enum LoggerKey: DependencyKey {
    public static let liveValue = Logger(handlers: [DebugLogHandler()])
    public static let previewValue = Logger(handlers: [DebugLogHandler()])
    public static let testValue = Logger(handlers: [DebugLogHandler()])
}

public extension DependencyValues {
    var logger: Logger {
        get { self[LoggerKey.self] }
        set { self[LoggerKey.self] = newValue }
    }
}
