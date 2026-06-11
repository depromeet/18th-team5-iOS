//
//  Bundle+.swift
//  Core
//
//  Created by 이정원 on 6/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

extension Bundle {
    static func value(of key: String) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}
