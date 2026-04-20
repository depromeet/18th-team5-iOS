//
//  MissionView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/14/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MissionView: View {
    private let store: StoreOf<MissionFeature>

    init(store: StoreOf<MissionFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {}
            .navigationTitle("미션")
    }
}
