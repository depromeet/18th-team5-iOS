//
//  CameraFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CameraFeature {
    @ObservableState
    public struct State: Equatable {
        public let overlayDate: String
        public let overlayLabel: String

        public var isFlashOn: Bool = false
        public var isFrontCamera: Bool = false
        public var currentZoomFactor: CGFloat = 1.0
        var baseZoomFactor: CGFloat = 1.0

        public init(overlayDate: String, overlayLabel: String) {
            self.overlayDate = overlayDate
            self.overlayLabel = overlayLabel
        }

        var activePreset: ZoomLevel? {
            ZoomLevel.allCases.first { abs($0.rawValue - currentZoomFactor) < 0.05 }
        }

        var minZoomFactor: CGFloat {
            isFrontCamera ? 1.0 : 0.5
        }

        var maxZoomFactor: CGFloat {
            isFrontCamera ? 5.0 : 10.0
        }

        var zoomLevelText: String {
            String(format: "%.1fx", currentZoomFactor)
        }
    }

    public enum ZoomLevel: CGFloat, CaseIterable, Equatable {
        case x0_5 = 0.5
        case x1 = 1.0
        case x2 = 2.0
        case x3 = 3.0

        var displayText: String {
            switch self {
            case .x0_5: ".5"
            case .x1: "1x"
            case .x2: "2"
            case .x3: "3"
            }
        }
    }

    public enum Action {
        case onAppear
        case onDisappear
        case captureButtonTapped
        case photoCaptured(Result<CapturedPhoto, Error>)
        case switchCameraTapped
        case cameraSwitched(Result<Void, Error>)
        case flashToggleTapped
        case zoomSelected(ZoomLevel)
        case pinchZoomChanged(CGFloat)
        case pinchZoomEnded
        case selfieZoomInTapped
        case selfieZoomOutTapped
        case closeButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didCapture(CapturedPhoto)
            case didCancel
        }
    }

    @Dependency(\.cameraClient) var cameraClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [zoom = state.currentZoomFactor] _ in
                    try await cameraClient.startSession()
                    try await cameraClient.setZoomFactor(zoom, false)
                }

            case .onDisappear:
                return .run { _ in
                    await cameraClient.stopSession()
                }

            case .captureButtonTapped:
                return .run { send in
                    await send(.photoCaptured(
                        Result { try await cameraClient.capturePhoto() }
                    ))
                }

            case let .photoCaptured(.success(photo)):
                return .send(.delegate(.didCapture(photo)))

            case .photoCaptured(.failure):
                return .none

            case .switchCameraTapped:
                return .run { send in
                    await send(.cameraSwitched(
                        Result { try await cameraClient.switchCamera() }
                    ))
                }

            case .cameraSwitched(.success):
                state.isFrontCamera.toggle()
                state.currentZoomFactor = 1.0
                state.baseZoomFactor = 1.0
                return .none

            case .cameraSwitched(.failure):
                return .none

            case .flashToggleTapped:
                state.isFlashOn.toggle()
                return .run { [isFlashOn = state.isFlashOn] _ in
                    await cameraClient.setFlashMode(isFlashOn)
                }

            case let .zoomSelected(level):
                state.currentZoomFactor = level.rawValue
                state.baseZoomFactor = level.rawValue
                return .run { _ in
                    try await cameraClient.setZoomFactor(level.rawValue, true)
                }

            case let .pinchZoomChanged(magnification):
                let newFactor = state.baseZoomFactor * magnification
                let clamped = min(max(newFactor, state.minZoomFactor), state.maxZoomFactor)
                state.currentZoomFactor = clamped
                return .run { _ in
                    try await cameraClient.setZoomFactor(clamped, false)
                }

            case .pinchZoomEnded:
                state.baseZoomFactor = state.currentZoomFactor
                return .none

            case .selfieZoomInTapped:
                let newFactor = min(state.currentZoomFactor + 0.5, state.maxZoomFactor)
                state.currentZoomFactor = newFactor
                state.baseZoomFactor = newFactor
                return .run { _ in
                    try await cameraClient.setZoomFactor(newFactor, true)
                }

            case .selfieZoomOutTapped:
                let newFactor = max(state.currentZoomFactor - 0.5, state.minZoomFactor)
                state.currentZoomFactor = newFactor
                state.baseZoomFactor = newFactor
                return .run { _ in
                    try await cameraClient.setZoomFactor(newFactor, true)
                }

            case .closeButtonTapped:
                return .send(.delegate(.didCancel))

            case .delegate:
                return .none
            }
        }
    }
}
