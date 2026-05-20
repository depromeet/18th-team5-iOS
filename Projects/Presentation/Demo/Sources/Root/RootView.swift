//
//  RootView.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Presentation
import SwiftUI

struct RootView: View {
    let store: StoreOf<RootFeature>

    var body: some View {
        MainView(store: store)
    }
}
