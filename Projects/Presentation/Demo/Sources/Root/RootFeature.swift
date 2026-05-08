//
//  RootFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Presentation

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        @Presents var camera: CameraFeature.State?
    }

    enum Action {
        case path(StackActionOf<Path>)
        case camera(PresentationAction<CameraFeature.Action>)
        case calendarTapped
        case cameraTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .calendarTapped:
                state.path.append(.calendar(.init()))
                return .none

            case .cameraTapped:
                state.camera = CameraFeature.State(
                    overlayDate: "2026.05.05",
                    overlayLabel: "Demo"
                )
                return .none

            case .camera(.presented(.delegate(.didCancel))),
                 .camera(.presented(.delegate(.didCapture))):
                state.camera = nil
                return .none

            case .camera, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$camera, action: \.camera) {
            CameraFeature()
        }
    }
}

@Reducer
enum Path {
    case calendar(CalendarFeature)
}

extension Path.State: Equatable {}
