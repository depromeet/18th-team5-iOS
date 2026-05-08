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

    var isDebug: Bool {
        Bundle.main.infoDictionary?["Environment"] as? String == "Dev"
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: Store(initialState: .init(isDebug: isDebug), reducer: {
                RootFeature()
            }))
        }
    }
}
