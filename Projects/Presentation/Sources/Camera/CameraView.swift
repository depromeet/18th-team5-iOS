//
//  CameraView.swift
//  Presentation
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import Core
import DesignSystem
import SwiftUI

public struct CameraView: View {
    private let store: StoreOf<CameraFeature>
    @State private var cameraController = CameraController()
    private let logger = Logger(handlers: [DebugLogHandler()])

    public init(store: StoreOf<CameraFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                closeButton
                previewSection

                if cameraController.isFrontCamera {
                    selfieZoomToggle
                } else {
                    zoomSelector
                }

                Spacer()

                bottomControls
                    .padding(.bottom, 98)
            }
        }
        .onAppear {
            Task {
                do {
                    try await cameraController.startSession()
                } catch {
                    logger.error(message: "카메라 세션 시작 실패: \(error)")
                }
            }
        }
        .onDisappear {
            Task {
                await cameraController.stopSession()
            }
        }
        .alert(
            "오류",
            isPresented: Binding(
                get: { cameraController.errorMessage != nil },
                set: { if !$0 { cameraController.clearError() } }
            )
        ) {
            Button("확인") { cameraController.clearError() }
        } message: {
            Text(cameraController.errorMessage ?? "")
        }
    }
}

// MARK: - Close Button & Preview

private extension CameraView {
    var closeButton: some View {
        Button {
            Task {
                await cameraController.stopSession()
                store.send(.cameraCancelled)
            }
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(Color.gray300)
                .clipShape(Circle())
        }
        .padding(.trailing, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    var previewSection: some View {
        GeometryReader { geometry in
            let size = geometry.size.width

            ZStack {
                CameraPreview(controller: cameraController)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 34))

                VStack {
                    HStack {
                        overlayBadges
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.leading, 16)

                    Spacer()
                }
                .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        do {
                            try cameraController.setZoomFromPinch(value.magnification)
                        } catch {
                            logger.warning(message: "핀치 줌 실패: \(error)")
                        }
                    }
                    .onEnded { _ in
                        cameraController.endPinchZoom()
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.top, 20)
    }

    var overlayBadges: some View {
        HStack(spacing: 6) {
            Text(store.overlayDate)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.5))
                .clipShape(Capsule())

            Text(store.overlayLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Zoom Controls

private extension CameraView {
    var selfieZoomToggle: some View {
        let isWide = cameraController.currentZoomFactor <= 1.0
        return Button {
            cameraController.toggleSelfieZoom()
        } label: {
            Image(systemName: isWide
                ? "arrow.down.right.and.arrow.up.left"
                : "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.gray500.opacity(0.5))
                .clipShape(Circle())
        }
        .frame(height: 32)
        .padding(.top, 24)
    }

    var zoomSelector: some View {
        GeometryReader { geometry in
            let sidePadding = geometry.size.width / 2 - 16

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(ZoomLevel.allCases, id: \.self) { level in
                            zoomButton(for: level)
                                .id(level)
                        }
                    }
                    .padding(.horizontal, sidePadding)
                }
                .onAppear {
                    proxy.scrollTo(cameraController.activePreset, anchor: .center)
                }
                .onChange(of: cameraController.activePreset) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 32)
        .padding(.top, 24)
    }

    func zoomButton(for level: ZoomLevel) -> some View {
        let isActive = cameraController.activePreset == level
        let text = cameraController.zoomButtonTexts[level] ?? level.displayText
        return Button {
            do {
                try cameraController.setZoom(level.rawValue, animated: true)
            } catch {
                logger.warning(message: "줌 레벨 변경 실패: \(error)")
            }
        } label: {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isActive ? .black : .gray500)
                .frame(width: 32, height: 32)
                .background(isActive ? Color.gray200 : Color.clear)
                .clipShape(Circle())
        }
    }
}

// MARK: - Bottom Controls

private extension CameraView {
    var bottomControls: some View {
        HStack {
            flashButton
            Spacer()
            captureButton
            Spacer()
            switchCameraButton
        }
        .padding(.horizontal, 53)
        .padding(.vertical, 10)
    }

    var flashButton: some View {
        Button {
            cameraController.toggleFlash()
        } label: {
            Image(systemName: cameraController.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(Color.gray300)
                .clipShape(Circle())
        }
    }

    var captureButton: some View {
        Button {
            Task {
                do {
                    let result = try await cameraController.capturePhoto()
                    await cameraController.stopSession()
                    store.send(.photoCaptured(result))
                } catch {
                    logger.error(message: "사진 촬영 실패: \(error)")
                }
            }
        } label: {
            Circle()
                .fill(.white)
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4)
                        .frame(width: 80, height: 80)
                )
        }
    }

    var switchCameraButton: some View {
        Button {
            Task {
                do {
                    try await cameraController.switchCamera()
                } catch {
                    logger.error(message: "카메라 전환 실패: \(error)")
                }
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(Color.gray300)
                .clipShape(Circle())
        }
    }
}
