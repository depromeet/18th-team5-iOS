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
    static let maxMemoLength = 200
    static let completionToastDuration: TimeInterval = 1.5

    public enum RecordAlert: Equatable {
        case submitFailed
    }

    @ObservableState
    public struct State: Equatable {
        var recordDate: Date
        var memo: String = ""
        var isSubmitting: Bool = false
        var alert: RecordAlert?
        var toast: ToastModel?
        var photo: RecordPhotoFeature.State

        public init(recordDate: Date) {
            self.recordDate = recordDate
            self.photo = RecordPhotoFeature.State(cameraOverlayLabel: "기록하기")
        }

        var isMemoLimitExceeded: Bool {
            memo.count > FreeRecordFeature.maxMemoLength
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
                      !state.isMemoLimitExceeded
                else { return .none }

                state.isSubmitting = true
                let imageData = state.photo.selectedImageData
                let recordDate = Self.recordDateFormatter.string(from: state.recordDate)
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
                        let recordId = try await calendarRecordRepository.completeFreeRecord(
                            recordDate,
                            objectKey,
                            memo.isEmpty ? nil : memo
                        )
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

            case .submitResponse(.failure):
                state.isSubmitting = false
                state.alert = .submitFailed
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
}
