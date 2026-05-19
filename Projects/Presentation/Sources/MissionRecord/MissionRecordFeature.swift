//
//  MissionRecordFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct MissionRecordFeature {
    @Reducer
    public struct CompletionModal {
        @ObservableState
        public struct State: Equatable {}

        public enum Action {
            case confirmTapped
        }

        public var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }

    @ObservableState
    public struct State: Equatable {
        var missionTitle: String
        var selectedImageData: Data?
        var memo: String = ""
        var isSubmitting: Bool = false
        @Presents var completionModal: CompletionModal.State?
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
        case completionModal(PresentationAction<CompletionModal.Action>)
        case camera(PresentationAction<CameraFeature.Action>)
    }

    public enum Delegate {
        case dismiss
        case submitted(imageData: Data?, memo: String)
    }

    @Dependency(\.date) var date

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"
        return formatter
    }()

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
                    overlayLabel: state.missionTitle,
                    date: date.now
                )
                return .none

            case let .imageSelected(data):
                state.selectedImageData = data
                return .none

            case .imageDeleteButtonTapped:
                state.selectedImageData = nil
                return .none

            case .submitButtonTapped:
                state.completionModal = CompletionModal.State()
                return .none

            case .completionModal(.presented(.confirmTapped)):
                state.completionModal = nil
                return .send(.delegate(.submitted(
                    imageData: state.selectedImageData,
                    memo: state.memo
                )))

            case .completionModal:
                return .none

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
        .ifLet(\.$completionModal, action: \.completionModal) {
            CompletionModal()
        }
        .ifLet(\.$camera, action: \.camera) {
            CameraFeature()
        }
    }
}
