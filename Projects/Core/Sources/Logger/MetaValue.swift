//
//  MetaValue.swift
//  Core
//
//  Created by Claude on 5/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public indirect enum MetaValue: Sendable, Equatable {
    case string(String)
    case array([MetaValue])
    case dictionary([String: MetaValue])
}

public typealias MetaData = [String: MetaValue]
