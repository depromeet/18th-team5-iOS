//
//  PhotoPickerFeature.swift
//  Presentation
//
//  Created by 진준호 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct PhotoPickerFeature {
    public enum PhotoPickerAlert: Equatable {
        case imageLoadFailed
    }

    @ObservableState
    public struct State: Equatable {
        public var assets: [PhotoAsset] = []
        public var selectedAssetId: String?
        public var isLimited: Bool = false
        public var isLoading: Bool = false
        public var alert: PhotoPickerAlert?

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case assetsLoaded([PhotoAsset], isLimited: Bool)
        case libraryDidChange
        case photoTapped(String)
        case manageLimitedTapped
        case confirmTapped
        case closeTapped
        case fullImageLoaded(Data?)
        case alertConfirmTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didConfirm(Data)
            case didCancel
            case manageLimitedRequested
        }
    }

    @Dependency(\.photoLibraryClient) var photoLibraryClient
    @Dependency(\.picturePermissionClient) var picturePermissionClient

    public init() {}

    private enum CancelID { case observeLibrary }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        await send(.libraryDidChange)
                    },
                    .run { send in
                        for await _ in photoLibraryClient.observeChanges() {
                            await send(.libraryDidChange)
                        }
                    }
                    .cancellable(id: CancelID.observeLibrary, cancelInFlight: true)
                )

            case .libraryDidChange:
                return .run { send in
                    let assets = await photoLibraryClient.fetchAssets()
                    let status = (try? await picturePermissionClient.status(.photoLibrary)) ?? .denied
                    await send(.assetsLoaded(assets, isLimited: status == .limited))
                }

            case let .assetsLoaded(assets, isLimited):
                state.assets = assets
                state.isLimited = isLimited
                if let selected = state.selectedAssetId,
                   !assets.contains(where: { $0.id == selected }) {
                    state.selectedAssetId = nil
                }
                return .none

            case let .photoTapped(id):
                state.selectedAssetId = (state.selectedAssetId == id) ? nil : id
                return .none

            case .manageLimitedTapped:
                return .send(.delegate(.manageLimitedRequested))

            case .confirmTapped:
                guard let id = state.selectedAssetId, !state.isLoading else { return .none }
                state.isLoading = true
                return .run { send in
                    let data = await photoLibraryClient.loadFullImage(id)
                    await send(.fullImageLoaded(data))
                }

            case let .fullImageLoaded(data):
                state.isLoading = false
                guard let data else {
                    state.selectedAssetId = nil
                    state.alert = .imageLoadFailed
                    return .none
                }
                return .merge(
                    .cancel(id: CancelID.observeLibrary),
                    .send(.delegate(.didConfirm(data)))
                )

            case .alertConfirmTapped:
                state.alert = nil
                return .none

            case .closeTapped:
                return .merge(
                    .cancel(id: CancelID.observeLibrary),
                    .send(.delegate(.didCancel))
                )

            case .delegate:
                return .none
            }
        }
    }
}
