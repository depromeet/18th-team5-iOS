//
//  CameraFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CameraFeature {
    @ObservableState
    public struct State: Equatable {
        static let selfieCloseUpZoom: CGFloat = 1.3

        public let overlayDate: String
        public let overlayLabel: String

        public var isFlashOn: Bool = false
        public var isFrontCamera: Bool = false
        public var currentZoomFactor: CGFloat = 1.0
        var baseZoomFactor: CGFloat = 1.0
        public var captureSession: CaptureSessionBox?
        public var errorMessage: String?

        public init(overlayDate: String, overlayLabel: String) {
            self.overlayDate = overlayDate
            self.overlayLabel = overlayLabel
        }

        var activePreset: ZoomLevel {
            if currentZoomFactor < 1.0 {
                return .x0_5
            } else if currentZoomFactor < 2.0 {
                return .x1
            } else if currentZoomFactor < 3.0 {
                return .x2
            } else {
                return .x3
            }
        }

        var zoomButtonTexts: [ZoomLevel: String] {
            var result: [ZoomLevel: String] = [:]
            for level in ZoomLevel.allCases {
                if activePreset == level {
                    if currentZoomFactor < 1.0 {
                        let digit = Int(round(currentZoomFactor * 10)) % 10
                        result[level] = ".\(digit)x"
                    } else {
                        let intPart = Int(currentZoomFactor)
                        let fraction = currentZoomFactor - CGFloat(intPart)
                        if fraction < 0.05 {
                            result[level] = "\(intPart)x"
                        } else {
                            result[level] = String(format: "%.1fx", currentZoomFactor)
                        }
                    }
                } else {
                    result[level] = level.displayText
                }
            }
            return result
        }

        var minZoomFactor: CGFloat {
            isFrontCamera ? 1.0 : 0.5
        }

        var maxZoomFactor: CGFloat {
            isFrontCamera ? 5.0 : 10.0
        }
    }

    public enum ZoomLevel: CGFloat, CaseIterable, Equatable {
        // swiftlint:disable:next identifier_name
        case x0_5 = 0.5
        case x1 = 1.0
        case x2 = 2.0
        case x3 = 3.0

        var displayText: String {
            switch self {
            case .x0_5: ".5"
            case .x1: "1"
            case .x2: "2"
            case .x3: "3"
            }
        }
    }

    public enum Action {
        case onAppear
        case captureButtonTapped
        case photoCaptured(Result<CapturedPhoto, Error>)
        case switchCameraTapped
        case cameraSwitched(Result<Void, Error>)
        case sessionStartFailed
        case flashToggleTapped
        case zoomSelected(ZoomLevel)
        case pinchZoomChanged(CGFloat)
        case pinchZoomEnded
        case selfieZoomToggleTapped
        case closeButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didCapture(CapturedPhoto)
            case didCancel
        }
    }

    private enum CancelID { case zoom }

    @Dependency(\.cameraClient) var cameraClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let box = cameraClient.getSession(),
                      let session = box.session as? AVCaptureSession else {
                    assertionFailure("getSession must return AVCaptureSession")
                    state.errorMessage = "카메라를 초기화할 수 없습니다."
                    return .none
                }
                state.captureSession = CaptureSessionBox(session)
                return .run { [zoom = state.currentZoomFactor] _ in
                    try await cameraClient.startSession()
                    try await cameraClient.setZoomFactor(zoom, false)
                } catch: { _, send in
                    await send(.sessionStartFailed)
                }

            case .captureButtonTapped:
                return .run { send in
                    await send(.photoCaptured(
                        Result { try await cameraClient.capturePhoto() }
                    ))
                }

            case let .photoCaptured(.success(photo)):
                return .run { [cameraClient] send in
                    await cameraClient.stopSession()
                    await send(.delegate(.didCapture(photo)))
                }

            case .photoCaptured(.failure):
                state.errorMessage = "사진 촬영에 실패했습니다."
                return .none

            case .sessionStartFailed:
                state.errorMessage = "카메라를 시작할 수 없습니다."
                return .none

            case .switchCameraTapped:
                return .run { send in
                    await send(.cameraSwitched(
                        Result { try await cameraClient.switchCamera() }
                    ))
                }

            case .cameraSwitched(.success):
                state.isFrontCamera.toggle()
                let initialZoom: CGFloat = state.isFrontCamera ? State.selfieCloseUpZoom : 1.0
                state.currentZoomFactor = initialZoom
                state.baseZoomFactor = initialZoom
                return .run { _ in
                    try? await cameraClient.setZoomFactor(initialZoom, false)
                }
                .cancellable(id: CancelID.zoom, cancelInFlight: true)

            case .cameraSwitched(.failure):
                state.errorMessage = "카메라 전환에 실패했습니다."
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
                .cancellable(id: CancelID.zoom, cancelInFlight: true)

            case let .pinchZoomChanged(magnification):
                guard !state.isFrontCamera else { return .none }
                let newFactor = state.baseZoomFactor * magnification
                let clamped = min(max(newFactor, state.minZoomFactor), state.maxZoomFactor)
                guard clamped != state.currentZoomFactor else { return .none }
                state.currentZoomFactor = clamped
                return .run { _ in
                    try await cameraClient.setZoomFactor(clamped, false)
                }
                .cancellable(id: CancelID.zoom, cancelInFlight: true)

            case .pinchZoomEnded:
                guard !state.isFrontCamera else { return .none }
                state.baseZoomFactor = state.currentZoomFactor
                return .none

            case .selfieZoomToggleTapped:
                let newFactor: CGFloat = state.currentZoomFactor <= 1.0 ? State.selfieCloseUpZoom : 1.0
                state.currentZoomFactor = newFactor
                state.baseZoomFactor = newFactor
                return .run { _ in
                    try? await cameraClient.setZoomFactor(newFactor, true)
                }
                .cancellable(id: CancelID.zoom, cancelInFlight: true)

            case .closeButtonTapped:
                return .run { [cameraClient] send in
                    await cameraClient.stopSession()
                    await send(.delegate(.didCancel))
                }

            case .delegate:
                return .none
            }
        }
    }
}
