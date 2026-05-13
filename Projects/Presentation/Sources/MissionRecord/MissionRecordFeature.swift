//
//  MissionRecordFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import Foundation

@Reducer
public struct MissionRecordFeature {
    @ObservableState
    public struct State: Equatable {
        var missionTitle: String
        var selectedImageData: Data?
        var memo: String = ""
        var isSubmitting: Bool = false
        @Presents var camera: CameraFeature.State?

        public init(missionTitle: String) {
            self.missionTitle = missionTitle
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case backButtonTapped
        case cameraButtonTapped
        case imageSelected(Data?)
        case submitButtonTapped
        case camera(PresentationAction<CameraFeature.Action>)
    }

    public enum Delegate {
        case dismiss
        case submitted(imageData: Data?, memo: String)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .send(.delegate(.dismiss))

            case .cameraButtonTapped:
                state.camera = CameraFeature.State(
                    overlayLabel: state.missionTitle
                )
                return .none

            case let .imageSelected(data):
                state.selectedImageData = data
                return .none

            case .submitButtonTapped:
                return .send(.delegate(.submitted(
                    imageData: state.selectedImageData,
                    memo: state.memo
                )))

            case let .camera(.presented(.delegate(.didCapture(result)))):
                state.selectedImageData = result.imageData
                state.camera = nil
                return .none

            case .camera(.presented(.delegate(.didCancel))):
                state.camera = nil
                return .none

            case .camera:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$camera, action: \.camera) {
            CameraFeature()
        }
    }
}
