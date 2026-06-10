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

    public enum RecordAlert: Equatable {
        case permissionDenied(PicturePermissionKind)
        case submitFailed
    }

    @ObservableState
    public struct State: Equatable {
        let missionId: Int
        let missionType: MissionType
        var missionTitle: String
        var missionDescription: String?
        var didRequestMissionRecordPage = false
        var selectedImageData: Data?
        var memo: String = ""
        var isSubmitting: Bool = false
        var alert: RecordAlert?
        var limitedPickerPresentationRequestID: UUID?
        @Presents var completionModal: CompletionModal.State?
        @Presents var camera: CameraFeature.State?
        @Presents var photoPicker: PhotoPickerFeature.State?

        public init(missionId: Int, missionTitle: String, missionType: MissionType) {
            self.missionId = missionId
            self.missionTitle = missionTitle
            self.missionType = missionType
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case missionRecordPageFetched(Mission?)
        case backButtonTapped
        case cameraButtonTapped
        case galleryButtonTapped
        case openCamera
        case openPhotoPicker
        case permissionResolved(PicturePermissionKind, granted: Bool)
        case imageSelected(Data?)
        case imageDeleteButtonTapped
        case submitButtonTapped
        case submitResponse(Result<Int, any Error>)
        case alertCancelTapped
        case alertOpenSettingsTapped
        case limitedPickerFinished
        case completionModal(PresentationAction<CompletionModal.Action>)
        case camera(PresentationAction<CameraFeature.Action>)
        case photoPicker(PresentationAction<PhotoPickerFeature.Action>)
    }

    public enum Delegate {
        case dismiss
        case submitted(imageData: Data?, memo: String)
    }

    @Dependency(\.date) private var date
    @Dependency(\.missionRepository) private var missionRepository
    @Dependency(\.picturePermissionClient) private var picturePermissionClient
    @Dependency(\.dismiss) private var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        EmptyReducer()
            .ifLet(\.$completionModal, action: \.completionModal) {
                CompletionModal()
            }
            .ifLet(\.$camera, action: \.camera) {
                CameraFeature()
            }
            .ifLet(\.$photoPicker, action: \.photoPicker) {
                PhotoPickerFeature()
            }

        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                guard !state.didRequestMissionRecordPage else { return .none }
                state.didRequestMissionRecordPage = true
                let missionId = state.missionId
                return .run { send in
                    do {
                        let mission = try await missionRepository.fetchMissionRecordPage(missionId)
                        await send(.missionRecordPageFetched(mission))
                    } catch {
                        await send(.missionRecordPageFetched(nil))
                    }
                }

            case .binding:
                return .none

            case let .missionRecordPageFetched(mission):
                guard let mission else { return .none }
                state.missionTitle = mission.title
                state.missionDescription = mission.description
                return .none

            case .backButtonTapped:
                return .send(.delegate(.dismiss))

            case .cameraButtonTapped:
                return resolvePermission(.camera)

            case .galleryButtonTapped:
                return resolvePermission(.photoLibrary)

            case .openCamera:
                state.camera = CameraFeature.State(
                    overlayLabel: state.missionTitle,
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

            case let .imageSelected(data):
                state.selectedImageData = data
                return .none

            case .imageDeleteButtonTapped:
                state.selectedImageData = nil
                return .none

            case .submitButtonTapped:
                guard !state.isSubmitting else { return .none }
                state.isSubmitting = true
                let missionId = state.missionId
                let missionType = state.missionType
                let imageData = state.selectedImageData
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)

                return .run { send in
                    do {
                        guard let imageData else {
                            throw DomainError.unknown("이미지가 필요합니다")
                        }
                        let objectKey = try await missionRepository.uploadImage(
                            imageData,
                            "\(UUID().uuidString).jpg",
                            "image/jpeg"
                        )
                        let completionId = try await missionRepository.completeMission(
                            missionId,
                            missionType,
                            objectKey,
                            memo.isEmpty ? nil : memo
                        )
                        await send(.submitResponse(.success(completionId)))
                    } catch {
                        await send(.submitResponse(.failure(error)))
                    }
                }

            case .submitResponse(.success):
                state.isSubmitting = false
                state.completionModal = CompletionModal.State()
                return .none

            case .submitResponse(.failure):
                state.isSubmitting = false
                state.alert = .submitFailed
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

            case .photoPicker:
                return .none

            case .delegate:
                return .run { _ in await dismiss() }
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
