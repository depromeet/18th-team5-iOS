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
            observeChanges: {
                store.changeStream()
            },
            saveImage: { data in
                try await store.saveImage(data)
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
        registerObserverIfNeeded()
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
            let resumeGate = OneTimeGate()
            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if isDegraded { return }
                guard resumeGate.closeIfOpen() else { return }

                let data = image?.cgImage.flatMap {
                    Self.jpegData(from: $0, compressionQuality: 0.8)
                }
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
                guard let data else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: Self.jpegData(from: data, compressionQuality: 0.9))
            }
        }
    }

    func saveImage(_ data: Data) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
        }
    }

    func changeStream() -> AsyncStream<Void> {
        registerObserverIfNeeded()

        return AsyncStream { continuation in
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

    private func registerObserverIfNeeded() {
        lock.lock()
        let shouldRegister = !didRegisterObserver
        if shouldRegister {
            didRegisterObserver = true
        }
        lock.unlock()

        guard shouldRegister else { return }
        PHPhotoLibrary.shared().register(self)
    }

    private static func jpegData(from data: Data, compressionQuality: CGFloat) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        return jpegData(from: image, compressionQuality: compressionQuality)
    }

    private static func jpegData(from image: CGImage, compressionQuality: CGFloat) -> Data? {
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output,
            "public.jpeg" as CFString,
            1,
            nil
        ) else {
            return nil
        }

        let options = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ] as CFDictionary
        CGImageDestinationAddImage(destination, image, options)

        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
}

private final class OneTimeGate: @unchecked Sendable {
    private let lock = NSLock()
    private var isOpen = true

    func closeIfOpen() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard isOpen else { return false }
        isOpen = false
        return true
    }
}
