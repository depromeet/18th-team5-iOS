//
//  ToastModel.swift
//  DesignSystem
//
//  Created by choijunios on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct ToastModel: Identifiable, Equatable {
    public let id = UUID()
    let createdAt: Date = .now
    let title: String
    let duration: TimeInterval
    let bottomInset: CGFloat
    let action: ToastAction?

    public init(
        title: String,
        duration: TimeInterval,
        bottomInset: CGFloat,
        action: ToastAction? = nil
    ) {
        self.title = title
        self.duration = duration
        self.bottomInset = bottomInset
        self.action = action
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

public extension ToastModel {
    struct ToastAction {
        let title: String
        let onAction: () -> Void

        public init(title: String, onAction: @escaping () -> Void) {
            self.title = title
            self.onAction = onAction
        }
    }
}
