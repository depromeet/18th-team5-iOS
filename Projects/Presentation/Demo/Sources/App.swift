//
//  App.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Data
import Presentation
import SwiftUI

@main
struct PresentationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoRootView()
        }
    }
}

struct DemoRootView: View {
    @State private var showCamera = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Button {
                showCamera = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                    Text("카메라 열기")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(width: 160, height: 160)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(
                store: Store(
                    initialState: CameraFeature.State(
                        overlayDate: "2026.05.05",
                        overlayLabel: "Demo"
                    )
                ) {
                    CameraFeature()
                }
            )
            .onDisappear { showCamera = false }
        }
    }
}
