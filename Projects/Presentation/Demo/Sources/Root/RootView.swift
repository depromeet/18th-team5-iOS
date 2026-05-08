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
    @Bindable var store: StoreOf<RootFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                Button("캘린더") {
                    store.send(.calendarTapped)
                }
                Button("카메라") {
                    store.send(.cameraTapped)
                }
            }
            .navigationTitle("Presentation Demo")
        } destination: { store in
            switch store.case {
            case let .calendar(calendarStore):
                ScrollView {
                    CalendarView(store: calendarStore)
                }
            }
        }
        .fullScreenCover(item: $store.scope(state: \.camera, action: \.camera)) { cameraStore in
            CameraView(store: cameraStore)
        }
    }
}
