//
//  CameraRepresentableView.swift
//  Camera
//
//  Created by 진준호 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import Core
import SwiftUI
import UIKit

// MARK: - CameraRepresentableView

public struct CameraRepresentableView: UIViewRepresentable {
    let proxy: CameraProxy
    let onStateChanged: (CameraStateSnapshot) -> Void
    let onCapture: (CapturedResult) -> Void
    let onError: (CameraError) -> Void

    public init(
        proxy: CameraProxy,
        onStateChanged: @escaping (CameraStateSnapshot) -> Void,
        onCapture: @escaping (CapturedResult) -> Void,
        onError: @escaping (CameraError) -> Void
    ) {
        self.proxy = proxy
        self.onStateChanged = onStateChanged
        self.onCapture = onCapture
        self.onError = onError
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func makeUIView(context: Context) -> PreviewUIView {
        let coordinator = context.coordinator
        let view = PreviewUIView()
        view.previewLayer.session = coordinator.cameraController.captureSession
        view.previewLayer.videoGravity = .resizeAspectFill

        coordinator.onStateChanged = onStateChanged
        coordinator.onCapture = onCapture
        coordinator.onError = onError
        coordinator.setupLifecycleObservers()

        proxy.handler = { [weak coordinator] action in
            coordinator?.handleAction(action)
        }

        return view
    }

    public func updateUIView(_ uiView: PreviewUIView, context: Context) {
        let coordinator = context.coordinator
        coordinator.onStateChanged = onStateChanged
        coordinator.onCapture = onCapture
        coordinator.onError = onError
    }

    // MARK: - Coordinator

    @MainActor
    public final class Coordinator {
        let cameraController = CameraController()
        private let logger = Logger(handlers: [DebugLogHandler()])

        var onStateChanged: ((CameraStateSnapshot) -> Void)?
        var onCapture: ((CapturedResult) -> Void)?
        var onError: ((CameraError) -> Void)?

        private var backgroundObserver: NSObjectProtocol?
        private var foregroundObserver: NSObjectProtocol?

        deinit {
            if let bg = backgroundObserver {
                NotificationCenter.default.removeObserver(bg)
            }
            if let fg = foregroundObserver {
                NotificationCenter.default.removeObserver(fg)
            }
        }

        func setupLifecycleObservers() {
            backgroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self, cameraController.isSessionRunning else { return }
                handleAction(.stopSession)
            }

            foregroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleAction(.startSession)
            }
        }

        func handleAction(_ action: CameraAction) {
            switch action {
            case .startSession:
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    do {
                        try await cameraController.startSession()
                        notifyStateChanged()
                    } catch let error as CameraError {
                        logger.error(message: "카메라 세션 시작 실패: \(error)")
                        onError?(error)
                    } catch {
                        logger.error(message: "카메라 세션 시작 실패: \(error)")
                        onError?(.sessionStartFailed)
                    }
                }

            case .stopSession:
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    await cameraController.stopSession()
                    notifyStateChanged()
                }

            case .switchCamera:
                guard !cameraController.isSwitchingCamera else { return }
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    do {
                        try await cameraController.switchCamera()
                        notifyStateChanged()
                    } catch let error as CameraError {
                        logger.error(message: "카메라 전환 실패: \(error)")
                        onError?(error)
                        notifyStateChanged()
                    } catch {
                        logger.error(message: "카메라 전환 실패: \(error)")
                        onError?(.switchFailed)
                        notifyStateChanged()
                    }
                }

            case .capturePhoto:
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    do {
                        let result = try await cameraController.capturePhoto()
                        await cameraController.stopSession()
                        notifyStateChanged()
                        onCapture?(result)
                    } catch let error as CameraError {
                        logger.error(message: "사진 촬영 실패: \(error)")
                        onError?(error)
                    } catch {
                        logger.error(message: "사진 촬영 실패: \(error)")
                        onError?(.captureFailed)
                    }
                }

            case .toggleFlash:
                cameraController.toggleFlash()
                notifyStateChanged()

            case let .setZoom(factor, animated):
                do {
                    try cameraController.setZoom(factor, animated: animated)
                    notifyStateChanged()
                } catch {
                    logger.warning(message: "줌 레벨 변경 실패: \(error)")
                }

            case let .setZoomFromPinch(magnification):
                do {
                    try cameraController.setZoomFromPinch(magnification)
                    notifyStateChanged()
                } catch {
                    logger.warning(message: "핀치 줌 실패: \(error)")
                }

            case .endPinchZoom:
                cameraController.endPinchZoom()
                notifyStateChanged()

            case .toggleSelfieZoom:
                cameraController.toggleSelfieZoom()
                notifyStateChanged()
            }
        }

        private func notifyStateChanged() {
            onStateChanged?(makeSnapshot())
        }

        private func makeSnapshot() -> CameraStateSnapshot {
            CameraStateSnapshot(
                isFrontCamera: cameraController.isFrontCamera,
                isFlashOn: cameraController.isFlashOn,
                currentZoomFactor: cameraController.currentZoomFactor,
                isSwitchingCamera: cameraController.isSwitchingCamera,
                isSessionRunning: cameraController.isSessionRunning,
                activePreset: cameraController.activePreset,
                zoomButtonTexts: cameraController.zoomButtonTexts
            )
        }
    }
}

// MARK: - PreviewUIView

public final class PreviewUIView: UIView {
    private let transitionOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = false
        return overlay
    }()

    private var lensSwitchObserver: NSObjectProtocol?

    override public class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    public var previewLayer: AVCaptureVideoPreviewLayer {
        guard let preview = layer as? AVCaptureVideoPreviewLayer else {
            assertionFailure("layerClass must be AVCaptureVideoPreviewLayer")
            return AVCaptureVideoPreviewLayer()
        }
        return preview
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(transitionOverlay)
        setupObserver()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }

    deinit {
        if let observer = lensSwitchObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        transitionOverlay.frame = bounds
    }

    private func setupObserver() {
        lensSwitchObserver = NotificationCenter.default.addObserver(
            forName: .cameraLensSwitched,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleLensSwitch()
        }
    }

    private func handleLensSwitch() {
        transitionOverlay.layer.removeAllAnimations()

        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.35) {
                self.transitionOverlay.alpha = 0.55
            }
            UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.65) {
                self.transitionOverlay.alpha = 0
            }
        }
    }
}
