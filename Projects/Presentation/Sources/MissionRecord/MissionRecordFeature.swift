//
//  MissionRecordFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct MissionRecordFeature {
    @Dependency(\.dismiss) private var dismiss

    @ObservableState
    public struct State: Equatable {
        var missionTitle: String
        var selectedImageData: Data?
        var memo: String = ""
        var isSubmitting: Bool = false
        var showCompletionModal: Bool = false
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
        case imageDeleteButtonTapped
        case submitButtonTapped
        case completionModalConfirmTapped
        case camera(PresentationAction<CameraFeature.Action>)
    }

    public enum Delegate {
        case dismiss
        case submitted(imageData: Data?, memo: String)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .cameraButtonTapped:
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy. M. d"
                let dateString = formatter.string(from: Date())
                state.camera = CameraFeature.State(
                    overlayDate: dateString,
                    overlayLabel: state.missionTitle
                )
                return .none

            case let .imageSelected(data):
                state.selectedImageData = data
                return .none

            case .imageDeleteButtonTapped:
                state.selectedImageData = nil
                return .none

            case .submitButtonTapped:
                state.showCompletionModal = true
                return .none

            case .completionModalConfirmTapped:
                state.showCompletionModal = false
                return .run { _ in await dismiss() }

            case let .camera(.presented(.delegate(.didCapture(photo)))):
                state.selectedImageData = photo.imageData
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
