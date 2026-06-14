//
//  RecordPhotoFeature.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct RecordPhotoFeature {
    public enum Alert: Equatable {
        case permissionDenied(PicturePermissionKind)
    }

    @ObservableState
    public struct State: Equatable {
        var cameraOverlayLabel: String
        var existingImageURL: URL?
        var selectedImageData: Data?
        var alert: Alert?
        var limitedPickerPresentationRequestID: UUID?
        @Presents var camera: CameraFeature.State?
        @Presents var photoPicker: PhotoPickerFeature.State?

        public init(cameraOverlayLabel: String, existingImageURL: URL? = nil) {
            self.cameraOverlayLabel = cameraOverlayLabel
            self.existingImageURL = existingImageURL
        }
    }

    public enum Action {
        case cameraButtonTapped
        case galleryButtonTapped
        case openCamera
        case openPhotoPicker
        case permissionResolved(PicturePermissionKind, granted: Bool)
        case imageDeleteButtonTapped
        case alertCancelTapped
        case alertOpenSettingsTapped
        case limitedPickerFinished
        case camera(PresentationAction<CameraFeature.Action>)
        case photoPicker(PresentationAction<PhotoPickerFeature.Action>)
    }

    @Dependency(\.date) private var date
    @Dependency(\.picturePermissionClient) private var picturePermissionClient

    public init() {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .ifLet(\.$camera, action: \.camera) {
                CameraFeature()
            }
            .ifLet(\.$photoPicker, action: \.photoPicker) {
                PhotoPickerFeature()
            }

        Reduce<State, Action> { state, action in
            switch action {
            case .cameraButtonTapped:
                return resolvePermission(.camera)

            case .galleryButtonTapped:
                return resolvePermission(.photoLibrary)

            case .openCamera:
                state.camera = CameraFeature.State(
                    overlayLabel: state.cameraOverlayLabel,
                    date: date.now
                )
                return .none

            case .openPhotoPicker:
                state.photoPicker = PhotoPickerFeature.State()
                return .none

            case let .permissionResolved(kind, granted):
                guard granted else {
                    state.alert = .permissionDenied(kind)
                    return .none
                }
                return .send(kind == .camera ? .openCamera : .openPhotoPicker)

            case .imageDeleteButtonTapped:
                state.selectedImageData = nil
                state.existingImageURL = nil
                return .none

            case .alertCancelTapped:
                state.alert = nil
                return .none

            case .alertOpenSettingsTapped:
                state.alert = nil
                return .run { _ in
                    await picturePermissionClient.openSettings()
                }

            case .limitedPickerFinished:
                state.limitedPickerPresentationRequestID = nil
                guard state.photoPicker != nil else { return .none }
                return .send(.photoPicker(.presented(.libraryDidChange)))

            case let .camera(.presented(.delegate(.didCapture(result)))):
                state.selectedImageData = result.imageData
                state.camera = nil
                return .none

            case .camera(.presented(.delegate(.didCancel))):
                state.camera = nil
                return .none

            case let .photoPicker(.presented(.delegate(.didConfirm(data)))):
                state.selectedImageData = data
                state.photoPicker = nil
                return .none

            case .photoPicker(.presented(.delegate(.didCancel))):
                state.photoPicker = nil
                return .none

            case .photoPicker(.presented(.delegate(.manageLimitedRequested))):
                state.limitedPickerPresentationRequestID = UUID()
                return .none

            case .camera, .photoPicker:
                return .none
            }
        }
    }

    private func resolvePermission(_ kind: PicturePermissionKind) -> Effect<Action> {
        .run { send in
            let status = await (try? picturePermissionClient.status(kind)) ?? .denied
            switch status {
            case .authorized, .limited:
                await send(kind == .camera ? .openCamera : .openPhotoPicker)
            case .notDetermined:
                let granted = await (try? picturePermissionClient.request(kind)) ?? false
                await send(.permissionResolved(kind, granted: granted))
            case .denied, .restricted:
                await send(.permissionResolved(kind, granted: false))
            }
        }
    }
}
