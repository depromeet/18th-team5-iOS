//
//  FreeRecordFeature.swift
//  Presentation
//
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Domain
import Foundation

@Reducer
public struct FreeRecordFeature {
    static let maxMemoLength = 48
    static let completionToastDuration: TimeInterval = 1.5

    public enum RecordAlert: Equatable {
        case submitFailed
        case freeRecordLimitExceeded
    }

    @ObservableState
    public struct State: Equatable {
        var recordDate: Date
        var editingRecordId: Int?
        var originalImageURL: URL?
        var originalMemo: String?
        var isRecordDateEditable: Bool = true
        var memo: String = ""
        var isSubmitting: Bool = false
        var alert: RecordAlert?
        var toast: ToastModel?
        var photo: RecordPhotoFeature.State

        public init(recordDate: Date) {
            self.recordDate = recordDate
            self.photo = RecordPhotoFeature.State(cameraOverlayLabel: "기록하기")
        }

        public init(
            editingRecordId: Int,
            recordDate: Date,
            imageURL: URL?,
            memo: String?
        ) {
            self.recordDate = recordDate
            self.editingRecordId = editingRecordId
            self.originalImageURL = imageURL
            self.originalMemo = memo
            self.isRecordDateEditable = false
            self.memo = memo ?? ""
            self.photo = RecordPhotoFeature.State(
                cameraOverlayLabel: "기록하기",
                existingImageURL: imageURL
            )
        }

        var isMemoLimitExceeded: Bool {
            memo.count > FreeRecordFeature.maxMemoLength
        }

        var isEditing: Bool {
            editingRecordId != nil
        }

        var hasEditedContent: Bool {
            photo.selectedImageData != nil
                || photo.existingImageURL != originalImageURL
                || memo != (originalMemo ?? "")
        }

        var hasRecordImage: Bool {
            photo.selectedImageData != nil || photo.existingImageURL != nil
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case submitButtonTapped
        case submitResponse(Result<Int, any Error>)
        case completionToastPresented
        case alertCancelTapped
        case photo(RecordPhotoFeature.Action)
    }

    @Dependency(\.calendarRecordRepository) private var calendarRecordRepository
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
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .submitButtonTapped:
                guard !state.isSubmitting,
                      !state.isMemoLimitExceeded,
                      state.hasRecordImage,
                      !state.isEditing || state.hasEditedContent
                else { return .none }

                state.isSubmitting = true
                let imageData = state.photo.selectedImageData
                let recordDate = Self.recordDateFormatter.string(from: state.recordDate)
                let memo = state.memo.trimmingCharacters(in: .whitespacesAndNewlines)
                let editingRecordId = state.editingRecordId

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

                        let recordId: Int
                        if let editingRecordId {
                            try await calendarRecordRepository.updateFreeRecord(
                                editingRecordId,
                                objectKey,
                                memo.isEmpty ? nil : memo
                            )
                            recordId = editingRecordId
                        } else {
                            guard let objectKey else {
                                throw DomainError.unknown("이미지가 필요합니다")
                            }
                            recordId = try await calendarRecordRepository.completeFreeRecord(
                                recordDate,
                                objectKey,
                                memo.isEmpty ? nil : memo
                            )
                        }
                        await send(.submitResponse(.success(recordId)))
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

            case let .submitResponse(.failure(error)):
                state.isSubmitting = false
                state.alert = Self.recordAlert(from: error)
                return .none

            case .completionToastPresented:
                return .run { _ in await dismiss() }

            case .alertCancelTapped:
                state.alert = nil
                return .none

            case .photo:
                return .none
            }
        }
    }

    private static let recordDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static func recordAlert(from error: any Error) -> RecordAlert {
        guard let domainError = error as? DomainError,
              case let .unknown(message) = domainError,
              message.contains("RECORD_409_FREE")
        else { return .submitFailed }

        return .freeRecordLimitExceeded
    }
}
