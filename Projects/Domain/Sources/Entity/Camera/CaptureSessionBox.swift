//
//  CaptureSessionBox.swift
//  Domain
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct CaptureSessionBox: Equatable, @unchecked Sendable {
    public let session: AnyObject

    public init(_ session: AnyObject) {
        self.session = session
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.session === rhs.session
    }
}
