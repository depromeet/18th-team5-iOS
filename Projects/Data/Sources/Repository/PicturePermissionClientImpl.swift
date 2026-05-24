//
//  PicturePermissionClientImpl.swift
//  Data
//
//  Created by 진준호 on 5/23/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import Dependencies
import Domain
import Photos
import UIKit

extension PicturePermissionClient: @retroactive DependencyKey {
    public static let liveValue: PicturePermissionClient = PicturePermissionClientImpl.live()
}

public enum PicturePermissionClientImpl {
    public static func live() -> PicturePermissionClient {
        PicturePermissionClient(
            status: { kind in
                switch kind {
                case .camera:
                    return AVCaptureDevice.authorizationStatus(for: .video).toDomain()
                case .photoLibrary:
                    return PHPhotoLibrary.authorizationStatus(for: .readWrite).toDomain()
                }
            },
            request: { kind in
                switch kind {
                case .camera:
                    return await AVCaptureDevice.requestAccess(for: .video)
                case .photoLibrary:
                    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                    return status == .authorized || status == .limited
                }
            },
            openSettings: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        )
    }
}

// MARK: - Mapping

private extension AVAuthorizationStatus {
    func toDomain() -> PicturePermissionStatus {
        switch self {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorized: .authorized
        @unknown default: .notDetermined
        }
    }
}

private extension PHAuthorizationStatus {
    func toDomain() -> PicturePermissionStatus {
        switch self {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorized: .authorized
        case .limited: .limited
        @unknown default: .notDetermined
        }
    }
}
