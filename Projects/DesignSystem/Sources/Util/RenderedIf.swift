//
//  RenderedIf.swift
//  DesignSystem
//
//  Created by 이정원 on 5/28/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct RenderedIf: ViewModifier {
    let condition: Bool

    public init(_ condition: Bool) {
        self.condition = condition
    }

    public func body(content: Content) -> some View {
        if condition { content }
    }
}

public extension View {
    func renderedIf(_ condition: Bool) -> some View {
        modifier(RenderedIf(condition))
    }
}
