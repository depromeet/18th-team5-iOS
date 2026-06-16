//
//  CalendarDetailFeature+Image.swift
//  Presentation
//
//  Created by choijunios on 6/14/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import DesignSystem
import Foundation

extension CalendarDetailFeature {
    func saveImage(_ state: inout State) -> Effect<Action> {
        guard let records = state.dateRecordCards,
              let card = records[safe: state.frontCardIndex]
        else { return .none }

        let term = state.term
        state.isLoading = true

        return .run { send in
            let status = await (try? picturePermissionClient.status(.photoLibrary)) ?? .denied
            let granted: Bool = switch status {
            case .authorized, .limited:
                true
            case .notDetermined:
                await (try? picturePermissionClient.request(.photoLibrary)) ?? false
            case .denied, .restricted:
                false
            }

            guard granted else {
                await send(.updateToast(.init(title: "사진 접근 권한이 필요해요", duration: 2.0, bottomInset: 108)))
                await send(.updateLoadingState(false))
                return
            }

            do {
                let data = try await cardImageRenderer.render(card, term)
                try await photoLibraryClient.saveImage(data)
                await send(.updateToast(.init(title: "이미지가 저장되었어요", duration: 1.5, bottomInset: 108)))
            } catch {
                await send(.updateToast(.init(title: "이미지 저장에 실패했어요", duration: 1.5, bottomInset: 108)))
            }
            await send(.updateLoadingState(false))
        }
    }

    func shareImage(_ state: inout State) -> Effect<Action> {
        guard let records = state.dateRecordCards,
              let card = records[safe: state.frontCardIndex]
        else { return .none }

        let term = state.term
        state.isLoading = true

        return .run { send in
            do {
                let data = try await cardImageRenderer.render(card, term)
                await send(.updateShareImageItem(ShareImageItem(imageData: data)))
            } catch {
                await send(.updateToast(.init(title: "이미지 공유에 실패했어요", duration: 1.5, bottomInset: 108)))
            }
            await send(.updateLoadingState(false))
        }
    }
}
