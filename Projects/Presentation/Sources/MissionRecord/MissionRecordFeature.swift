//
//  MissionRecordFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

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
        var showCamera: Bool = false

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
                return .send(.delegate(.dismiss))

            case .cameraButtonTapped:
                state.showCamera = true
                return .none

            case let .imageSelected(data):
                state.selectedImageData = data
                return .none

            case .submitButtonTapped:
                return .send(.delegate(.submitted(
                    imageData: state.selectedImageData,
                    memo: state.memo
                )))

            case .delegate:
                return .none
            }
        }
    }
}
