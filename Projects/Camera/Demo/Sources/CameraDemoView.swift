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
    @State private var proxy = CameraProxy()
    @State private var cameraState = CameraStateSnapshot.initial
    @State private var cameraError: CameraError?
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
                CameraRepresentableView(
                    proxy: proxy,
                    onStateChanged: { cameraState = $0 },
                    onCapture: { store.send(.photoCaptured($0)) },
                    onError: { cameraError = $0 }
                )
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
                        proxy.send(.setZoomFromPinch(magnification: value.magnification))
                    }
                    .onEnded { _ in
                        proxy.send(.endPinchZoom)
                    }
            )

            if cameraState.isFrontCamera {
                selfieZoomToggle
                    .padding(.top, 24)
            } else {
                zoomControls
                    .padding(.top, 24)
            }

            Spacer()

            bottomControls
                .padding(.bottom, 98)
        }
        .onAppear { proxy.send(.startSession) }
        .onDisappear { proxy.send(.stopSession) }
        .alert(
            "오류",
            isPresented: Binding(
                get: { cameraError != nil },
                set: { if !$0 { cameraError = nil } }
            )
        ) {
            Button("확인") { cameraError = nil }
        } message: {
            Text(cameraError?.userMessage ?? "")
        }
    }

    var closeButton: some View {
        Button {
            proxy.send(.stopSession)
            store.send(.cameraCancelled)
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

    var selfieZoomToggle: some View {
        let isWide = cameraState.currentZoomFactor <= 1.0
        return Button {
            proxy.send(.toggleSelfieZoom)
        } label: {
            Image(
                systemName: isWide
                    ? "arrow.down.right.and.arrow.up.left"
                    : "arrow.up.left.and.arrow.down.right"
            )
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(Color.gray.opacity(0.5))
            .clipShape(Circle())
        }
        .frame(height: 32)
    }

    var zoomControls: some View {
        HStack(spacing: 16) {
            ForEach(ZoomLevel.allCases, id: \.self) { level in
                let isActive = cameraState.activePreset == level
                Button {
                    proxy.send(.setZoom(factor: level.rawValue, animated: true))
                } label: {
                    Text(cameraState.zoomButtonTexts[level] ?? level.displayText)
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
                proxy.send(.toggleFlash)
            } label: {
                Image(systemName: cameraState.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                proxy.send(.capturePhoto)
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
                proxy.send(.switchCamera)
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 20))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .disabled(cameraState.isSwitchingCamera)
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
