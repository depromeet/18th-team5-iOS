//
//  DeviceShakeViewModifier.swift
//  DesignSystem
//
//  Created by 이정원 on 6/13/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation
import SwiftUI

private struct DeviceShakeViewModifier: ViewModifier {
    private let action: () -> Void

    fileprivate init(action: @escaping () -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(
                NotificationCenter.default.publisher(for: .deviceShaked),
                perform: { _ in action() }
            )
    }
}

public extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(action: action))
    }
}

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceShaked, object: nil)
        }
    }
}
