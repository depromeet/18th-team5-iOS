//
//  TabBarVisibilityKey.swift
//  Presentation
//
//  Created by choijunios on 5/31/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

extension SharedReaderKey where Self == InMemoryKey<Bool> {
    static var tabBarVisibility: Self {
        inMemory("tabBarVisibility")
    }
}
