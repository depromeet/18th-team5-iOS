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
        let missionId: Int
        let missionType: MissionType
        var missionTitle: String
        var missionDescription: String?
        var didRequestMissionRecordPage = false
        var memo: String = ""
        var isSubmitting: Bool = false
        var alert: RecordAlert?
        var toast: ToastModel?
        var photo: RecordPhotoFeature.State

        public init(missionId: Int, missionTitle: String, missionType: MissionType) {
            self.missionId = missionId
            self.missionTitle = missionTitle
            self.missionType = missionType
            self.photo = RecordPhotoFeature.State(cameraOverlayLabel: missionTitle)
        }

        var isMemoLimitExceeded: Bool {
            memo.count > MissionRecordFeature.maxMemoLength
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case missionRecordPageFetched(Mission?)
        case backButtonTapped
        case submitButtonTapped
        case submitResponse(Result<Int, any Error>)
        case completionToastPresented
        case alertCancelTapped
        case dismissAll
        case photo(RecordPhotoFeature.Action)
    }

    public enum Delegate {
        case dismiss
        case submitted(imageData: Data?, memo: String)
    }

    @Dependency(\.missionRepository) private var missionRepository
    @Dependency(\.imageUploadRepository) private var imageUploadRepository
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
                state.photo.cameraOverlayLabel = mission.title
                return .none

            case .backButtonTapped:
                return .send(.delegate(.dismiss))

            case .submitButtonTapped:
                guard !state.isSubmitting,
                      !state.isMemoLimitExceeded
                else { return .none }
                state.isSubmitting = true
                let missionId = state.missionId
                let missionType = state.missionType
                let imageData = state.photo.selectedImageData
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)

                return .run { send in
                    do {
                        guard let imageData else {
                            throw DomainError.unknown("이미지가 필요합니다")
                        }
                        let objectKey = try await imageUploadRepository.uploadImage(
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

            case .alertCancelTapped:
                state.alert = nil
                return .none

            case .dismissAll:
                state.photo.camera = nil
                state.photo.photoPicker = nil
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
