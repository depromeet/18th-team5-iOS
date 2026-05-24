//
//  CameraDemoFeature.swift
//  CameraDemo
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import Foundation

@Reducer
struct CameraDemoFeature {
    @ObservableState
    struct State: Equatable {
        var overlayDate: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: Date())
        }()

        var overlayLabel: String = "데모 미션"
        var capturedImageData: Data?
        var showCamera: Bool = true
    }

    enum Action {
        case photoCaptured(CapturedResult)
        case cameraCancelled
        case retryButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .photoCaptured(result):
                state.capturedImageData = result.imageData
                state.showCamera = false
                return .none

            case .cameraCancelled:
                state.showCamera = false
                return .none

            case .retryButtonTapped:
                state.capturedImageData = nil
                state.showCamera = true
                return .none
            }
        }
    }
}
