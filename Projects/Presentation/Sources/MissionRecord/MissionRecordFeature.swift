//
//  MissionRecordFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct MissionRecordFeature {
    static let maxMemoLength = 48
    static let completionToastDuration: TimeInterval = 1.5

    public enum RecordAlert: Equatable {
        case submitFailed
    }

    @ObservableState
    public struct State: Equatable {
        let missionType: MissionType
        var mission: Mission
        var editingCompletionId: Int?
        var originalImageURL: URL?
        var originalMemo: String?
        var memo: String = ""
        var isSubmitting: Bool = false
        var alert: RecordAlert?
        var toast: ToastModel?
        var photo: RecordPhotoFeature.State

        public init(missionId: Int, missionTitle: String, missionDescription: String? = nil, missionType: MissionType) {
            self.mission = .init(id: missionId, title: missionTitle, description: missionDescription)
            self.missionType = missionType
            self.photo = RecordPhotoFeature.State(cameraOverlayLabel: missionTitle)
        }

        public init(
            editingCompletionId: Int,
            missionTitle: String,
            missionDescription: String?,
            missionType: MissionType,
            imageURL: URL?,
            memo: String?
        ) {
            self.mission = .init(id: 0, title: missionTitle, description: missionDescription)
            self.missionType = missionType
            self.editingCompletionId = editingCompletionId
            self.originalImageURL = imageURL
            self.originalMemo = memo
            self.memo = memo ?? ""
            self.photo = RecordPhotoFeature.State(
                cameraOverlayLabel: missionTitle,
                existingImageURL: imageURL
            )
        }

        var isMemoLimitExceeded: Bool {
            memo.count > MissionRecordFeature.maxMemoLength
        }

        var isEditing: Bool {
            editingCompletionId != nil
        }

        var hasEditedContent: Bool {
            photo.selectedImageData != nil
                || photo.existingImageURL != originalImageURL
                || memo != (originalMemo ?? "")
        }

        var hasRecordImage: Bool {
            photo.selectedImageData != nil || photo.existingImageURL != nil
        }

        var missionTitle: String {
            mission.title
        }

        var missionDescription: String? {
            mission.description
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case backButtonTapped
        case submitButtonTapped
        case submitResponse(Result<Int, any Error>)
        case completionToastPresented
        case memoFieldFocused
        case alertCancelTapped
        case dismissAll
        case photo(RecordPhotoFeature.Action)
    }

    public enum Delegate {
        case dismiss
        case submitted(imageData: Data?, memo: String)
    }

    @Dependency(\.missionRepository) private var missionRepository
    @Dependency(\.calendarRecordRepository) private var calendarRecordRepository
    @Dependency(\.imageUploadRepository) private var imageUploadRepository
    @Dependency(\.analyticsClient) private var analyticsClient
    @Dependency(\.dismiss) private var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.photo, action: \.photo) {
            RecordPhotoFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                logRecordScreenView(state)
                return .none

            case .binding:
                return .none

            case .backButtonTapped:
                return .send(.delegate(.dismiss))

            case .submitButtonTapped:
                guard !state.isSubmitting,
                      !state.isMemoLimitExceeded,
                      state.hasRecordImage,
                      !state.isEditing || state.hasEditedContent
                else { return .none }
                state.isSubmitting = true
                let missionId = state.mission.id
                let missionType = state.missionType
                let imageData = state.photo.selectedImageData
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                let editingCompletionId = state.editingCompletionId

                return .run { send in
                    do {
                        let objectKey: String? = if let imageData {
                            try await imageUploadRepository.uploadImage(
                                imageData,
                                "\(UUID().uuidString).jpg",
                                "image/jpeg"
                            )
                        } else {
                            nil
                        }

                        let completionId: Int
                        if let editingCompletionId {
                            try await calendarRecordRepository.updateMissionCompletion(
                                editingCompletionId,
                                objectKey,
                                memo.isEmpty ? nil : memo
                            )
                            completionId = editingCompletionId
                        } else {
                            guard let objectKey else {
                                throw DomainError.unknown("이미지가 필요합니다")
                            }
                            completionId = try await missionRepository.completeMission(
                                missionId,
                                missionType,
                                objectKey,
                                memo.isEmpty ? nil : memo
                            )
                        }
                        await send(.submitResponse(.success(completionId)))
                    } catch {
                        await send(.submitResponse(.failure(error)))
                    }
                }

            case .submitResponse(.success):
                logRecordConfirmSubmit(state)
                state.isSubmitting = false
                state.toast = ToastModel(
                    title: "기록이 완료되었어요!",
                    duration: Self.completionToastDuration,
                    bottomInset: 108
                )
                return .run { send in
                    try? await Task.sleep(for: .milliseconds(100))
                    await send(.completionToastPresented)
                }

            case .submitResponse(.failure):
                state.isSubmitting = false
                state.alert = .submitFailed
                return .none

            case .completionToastPresented:
                return .send(.delegate(.submitted(
                    imageData: state.photo.selectedImageData,
                    memo: state.memo
                )))

            case .memoFieldFocused:
                logRecordMemoTap(state)
                return .none

            case .alertCancelTapped:
                state.alert = nil
                return .none

            case .dismissAll:
                state.photo.camera = nil
                state.photo.photoPicker = nil
                return .none

            case .photo(.cameraButtonTapped):
                logRecordPictureTap(state, .camera)
                return .none

            case .photo(.galleryButtonTapped):
                logRecordPictureTap(state, .photoLibrary)
                return .none

            case .photo:
                return .none

            case .delegate(.dismiss):
                return .run { _ in await dismiss() }

            case .delegate(.submitted):
                return .run { _ in await dismiss() }
            }
        }
    }
}

private extension MissionRecordFeature {
    func logRecordScreenView(_ state: State) {
        guard !state.isEditing else { return }
        analyticsClient.logRecordScreenView(state.mission)
    }

    func logRecordPictureTap(_ state: State, _ source: PicturePermissionKind) {
        guard !state.isEditing else { return }
        analyticsClient.logRecordPictureTap(source, state.mission.id)
    }

    func logRecordMemoTap(_ state: State) {
        guard !state.isEditing else { return }
        analyticsClient.logRecordMemoTap(state.mission.id, state.hasRecordImage)
    }

    func logRecordConfirmSubmit(_ state: State) {
        guard !state.isEditing else { return }
        analyticsClient.logRecordConfirmSubmit(
            state.mission,
            state.hasRecordImage,
            !state.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        )
    }
}
