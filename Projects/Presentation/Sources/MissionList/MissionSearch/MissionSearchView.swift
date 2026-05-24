//
//  MissionSearchView.swift
//  Presentation
//
//  Created by 이정원 on 5/24/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MissionSearchView: View {
    private let store: StoreOf<MissionSearchFeature>

    public init(store: StoreOf<MissionSearchFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Mission Search")
    }
}
