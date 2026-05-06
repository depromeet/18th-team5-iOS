//
//  CameraPreviewView.swift
//  Presentation
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import SwiftUI
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

final class PreviewUIView: UIView {
    private let transitionOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()

    private var lensSwitchObserver: NSObjectProtocol?

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(transitionOverlay)
        setupObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(transitionOverlay)
        setupObserver()
    }

    deinit {
        if let observer = lensSwitchObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        transitionOverlay.frame = bounds
    }

    private func setupObserver() {
        lensSwitchObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("CameraLensSwitched"),
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
