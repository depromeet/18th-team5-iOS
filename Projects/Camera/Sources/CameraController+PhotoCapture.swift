//
//  CameraController+PhotoCapture.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraController: AVCapturePhotoCaptureDelegate {
    public nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let continuation = mutableState.withLock { state -> CheckedContinuation<CapturedResult, Error>? in
            let result = state.photoContinuation
            state.photoContinuation = nil
            return result
        }
        guard let continuation else { return }

        if let error {
            continuation.resume(throwing: error)
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            continuation.resume(throwing: CameraError.captureDataMissing)
            return
        }

        guard let originalImage = UIImage(data: data) else {
            continuation.resume(throwing: CameraError.captureDataMissing)
            return
        }

        let squareImage = cropToSquare(originalImage)
        guard let squareData = squareImage.jpegData(compressionQuality: 0.9) else {
            continuation.resume(throwing: CameraError.captureDataMissing)
            return
        }

        let position = mutableState.withLock { $0.currentPosition }
        let device = currentDevice()
        let capturedResult = CapturedResult(
            imageData: squareData,
            capturedAt: Date(),
            cameraPosition: position == .front ? .front : .back,
            zoomLevel: Double(device?.videoZoomFactor ?? 1.0)
        )

        continuation.resume(returning: capturedResult)
    }

    nonisolated func cropToSquare(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let size = min(cgImage.width, cgImage.height)
        let x = (cgImage.width - size) / 2
        let y = (cgImage.height - size) / 2
        let cropRect = CGRect(x: x, y: y, width: size, height: size)

        guard let cropped = cgImage.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
}
