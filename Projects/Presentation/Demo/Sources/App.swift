//
//  App.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation
import Presentation
import SwiftUI

@main
struct PresentationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store:
                .init(initialState: .init()) {
                    RootFeature()
                        .dependency(\.calendarRepository, .mock)
                }
            )
        }
    }
}
