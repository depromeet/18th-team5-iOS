//
//  App.swift
//  CameraDemo
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

@main
struct CameraDemoApp: App {
    var body: some Scene {
        WindowGroup {
            CameraDemoView(
                store: .init(initialState: .init()) {
                    CameraDemoFeature()
                }
            )
        }
    }
}
