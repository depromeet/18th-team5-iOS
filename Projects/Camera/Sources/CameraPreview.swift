//
//  CameraPreview.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import SwiftUI
import UIKit

public struct CameraPreview: UIViewRepresentable {
    private let session: AVCaptureSession

    public init(controller: CameraController) {
        self.session = controller.captureSession
    }

    public func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    public func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

public final class PreviewUIView: UIView {
    private let transitionOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
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
