//
//  App.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Data
import Domain
import Foundation
import Presentation
import SwiftUI

@Reducer
struct DemoRootFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var camera: CameraFeature.State?
    }

    enum Action {
        case openCameraTapped
        case camera(PresentationAction<CameraFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .openCameraTapped:
                state.camera = CameraFeature.State(
                    overlayDate: "2026.05.05",
                    overlayLabel: "Demo"
                )
                return .none

            case .camera(.presented(.delegate(.didCancel))),
                 .camera(.presented(.delegate(.didCapture))):
                state.camera = nil
                return .none

            case .camera:
                return .none
            }
        }
        .ifLet(\.$camera, action: \.camera) {
            CameraFeature()
        }
    }
}

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

struct DemoRootView: View {
    @Bindable var store: StoreOf<DemoRootFeature>

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Button {
                store.send(.openCameraTapped)
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
        .fullScreenCover(item: $store.scope(state: \.camera, action: \.camera)) { cameraStore in
            CameraView(store: cameraStore)
        }
    }
}
