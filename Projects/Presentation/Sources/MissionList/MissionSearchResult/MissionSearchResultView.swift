//
//  MissionSearchResultView.swift
//  Presentation
//
//  Created by 이정원 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct MissionSearchResultView: View {
    private let store: StoreOf<MissionSearchResultFeature>

    public init(store: StoreOf<MissionSearchResultFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Result")
    }
}
