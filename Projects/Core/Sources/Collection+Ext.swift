//
//  Collection+Ext.swift
//  Core
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

public extension Collection {
    subscript(safe index: Index?) -> Element? {
        guard let index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}
