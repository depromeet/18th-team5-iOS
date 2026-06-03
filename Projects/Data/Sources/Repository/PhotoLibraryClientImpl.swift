//
//  PhotoLibraryClientImpl.swift
//  Data
//
//  Created by 진준호 on 5/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import Domain
import Photos
import PhotosUI
import UIKit

extension PhotoLibraryClient: @retroactive DependencyKey {
    public static let liveValue: PhotoLibraryClient = PhotoLibraryClientImpl.live()
}

public enum PhotoLibraryClientImpl {
    public static func live() -> PhotoLibraryClient {
        let store = PhotoLibraryStore()

        return PhotoLibraryClient(
            fetchAssets: {
                await store.fetchAssets()
            },
            loadThumbnail: { id, size in
                await store.loadThumbnail(id: id, size: size)
            },
            loadFullImage: { id in
                await store.loadFullImage(id: id)
            },
            presentLimitedPicker: {
                await store.presentLimitedPicker()
            },
            observeChanges: {
                store.changeStream()
            }
        )
    }
}

// MARK: - PhotoLibraryStore

private final class PhotoLibraryStore: NSObject, PHPhotoLibraryChangeObserver, @unchecked Sendable {
    private let imageManager = PHCachingImageManager()
    private let lock = NSLock()
    private var continuations: [UUID: AsyncStream<Void>.Continuation] = [:]
    private var didRegisterObserver = false

    func fetchAssets() async -> [PhotoAsset] {
        await registerObserverIfNeeded()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: options)

        var assets: [PhotoAsset] = []
        assets.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in
            assets.append(PhotoAsset(id: asset.localIdentifier, creationDate: asset.creationDate))
        }
        return assets
    }

    func loadThumbnail(id: String, size: CGSize) async -> Data? {
        guard let asset = phAsset(for: id) else { return nil }
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        return await withCheckedContinuation { (continuation: CheckedContinuation<Data?, Never>) in
            var hasResumed = false
            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if isDegraded { return }
                guard !hasResumed else { return }
                hasResumed = true
                let data = image?.jpegData(compressionQuality: 0.8)
                continuation.resume(returning: data)
            }
        }
    }

    func loadFullImage(id: String) async -> Data? {
        guard let asset = phAsset(for: id) else { return nil }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        return await withCheckedContinuation { (continuation: CheckedContinuation<Data?, Never>) in
            imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                guard let data, let image = UIImage(data: data) else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: image.jpegData(compressionQuality: 0.9))
            }
        }
    }

    @MainActor
    func presentLimitedPicker() {
        guard let rootVC = Self.topViewController() else { return }
        let library: PHPhotoLibrary = PHPhotoLibrary.shared()
        library.presentLimitedLibraryPicker(from: rootVC)
    }

    func changeStream() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let token = UUID()
            lock.lock()
            continuations[token] = continuation
            lock.unlock()

            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                self.lock.lock()
                self.continuations.removeValue(forKey: token)
                self.lock.unlock()
            }
        }
    }

    // MARK: PHPhotoLibraryChangeObserver

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        lock.lock()
        let snapshot = Array(continuations.values)
        lock.unlock()
        for continuation in snapshot {
            continuation.yield(())
        }
    }

    // MARK: Helpers

    private func phAsset(for id: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        return result.firstObject
    }

    @MainActor
    private func registerObserverIfNeeded() {
        if didRegisterObserver { return }
        didRegisterObserver = true
        PHPhotoLibrary.shared().register(self)
    }

    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let keyWindow = scenes.flatMap(\.windows).first(where: \.isKeyWindow)
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
