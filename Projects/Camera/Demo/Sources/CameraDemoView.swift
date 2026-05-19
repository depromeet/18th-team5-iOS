//
//  CameraDemoView.swift
//  CameraDemo
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Camera
import ComposableArchitecture
import Core
import SwiftUI

struct CameraDemoView: View {
    let store: StoreOf<CameraDemoFeature>
    @State private var cameraController = CameraController()
    private let logger = Logger(handlers: [DebugLogHandler()])

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if store.showCamera {
                cameraLayer
            } else if let imageData = store.capturedImageData,
                      let uiImage = UIImage(data: imageData) {
                resultLayer(uiImage: uiImage)
            } else {
                cancelledLayer
            }
        }
    }
}

// MARK: - Camera Layer

private extension CameraDemoView {
    var cameraLayer: some View {
        VStack(spacing: 0) {
            closeButton

            ZStack {
                CameraPreview(controller: cameraController)
                    .clipShape(RoundedRectangle(cornerRadius: 34))

                VStack {
                    HStack(spacing: 6) {
                        badge(store.overlayDate)
                        badge(store.overlayLabel)
                        Spacer()
                    }
                    .padding(16)
                    Spacer()
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 20)
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

            zoomControls
                .padding(.top, 24)

            Spacer()

            bottomControls
                .padding(.bottom, 98)
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
                .background(Color.white)
                .clipShape(Circle())
        }
        .padding(.trailing, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    func badge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.5))
            .clipShape(Capsule())
    }

    var zoomControls: some View {
        HStack(spacing: 16) {
            ForEach(ZoomLevel.allCases, id: \.self) { level in
                let isActive = cameraController.activePreset == level
                Button {
                    do {
                        try cameraController.setZoom(level.rawValue, animated: true)
                    } catch {
                        logger.warning(message: "줌 레벨 변경 실패: \(error)")
                    }
                } label: {
                    Text(cameraController.zoomButtonTexts[level] ?? level.displayText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isActive ? .black : .gray)
                        .frame(width: 32, height: 32)
                        .background(isActive ? Color.white.opacity(0.8) : Color.clear)
                        .clipShape(Circle())
                }
            }
        }
        .frame(height: 32)
    }

    var bottomControls: some View {
        HStack {
            Button {
                cameraController.toggleFlash()
            } label: {
                Image(systemName: cameraController.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Spacer()

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

            Spacer()

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
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 53)
    }
}

// MARK: - Result Layer

private extension CameraDemoView {
    func resultLayer(uiImage: UIImage) -> some View {
        VStack(spacing: 24) {
            Text("촬영 완료")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)

            retryButton
        }
    }

    var cancelledLayer: some View {
        VStack(spacing: 24) {
            Text("촬영 취소됨")
                .font(.title2.bold())
                .foregroundStyle(.white)

            retryButton
        }
    }

    var retryButton: some View {
        Button {
            store.send(.retryButtonTapped)
        } label: {
            Text("다시 촬영하기")
                .font(.body.bold())
                .foregroundStyle(.black)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(.white)
                .clipShape(Capsule())
        }
    }
}
