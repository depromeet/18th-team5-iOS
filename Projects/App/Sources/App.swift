//
//  App.swift
//  App
//
//  Created by 이정원 on 4/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Data
import Presentation
import SwiftUI

@main
struct PeaktimeApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            RootView(store: Store(initialState: .init(), reducer: {
                RootFeature()
            }))
        }
    }
}
