//
//  CameraFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import Foundation

@Reducer
public struct CameraFeature {
    @ObservableState
    public struct State: Equatable {
        public let overlayDate: String
        public let overlayLabel: String

        public init(overlayLabel: String, date: Date = Date()) {
            self.overlayDate = Self.formatDate(date)
            self.overlayLabel = overlayLabel
        }

        private static func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: date)
        }
    }

    public enum Action: Equatable {
        case photoCaptured(CapturedResult)
        case cameraCancelled
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didCapture(CapturedResult)
            case didCancel
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .photoCaptured(result):
                return .send(.delegate(.didCapture(result)))

            case .cameraCancelled:
                return .send(.delegate(.didCancel))

            case .delegate:
                return .none
            }
        }
    }
}
