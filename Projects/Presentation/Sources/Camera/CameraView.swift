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
import Domain
import SwiftUI

public struct CameraView: View {
    private let store: StoreOf<CameraFeature>
    @State private var proxy = CameraProxy()
    @State private var cameraState = CameraStateSnapshot.initial
    @State private var cameraError: CameraError?
    @State private var isFlashButtonFeedbackVisible = false
    @State private var isSwitchCameraButtonFeedbackVisible = false
    @State private var flashButtonFeedbackTask: Task<Void, Never>?
    @State private var switchCameraButtonFeedbackTask: Task<Void, Never>?

    public init(store: StoreOf<CameraFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                closeButton
                previewSection

                if cameraState.isFrontCamera {
                    selfieZoomToggle
                } else {
                    zoomSelector
                }

                bottomControls
                    .padding(.top, 12)

                Spacer()
            }
        }
        .onAppear { proxy.send(.startSession) }
        .onDisappear {
            proxy.send(.stopSession)
            clearControlFeedback()
        }
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
}

// MARK: - Close Button & Preview

private extension CameraView {
    var closeButton: some View {
        Button {
            proxy.send(.stopSession)
            store.send(.cameraCancelled)
        } label: {
            Image.icClose
                .resizable()
                .frame(width: 20, height: 20)
                .padding(12)
                .background(Color.whiteAlpha600)
                .clipShape(.circle)
        }
        .padding(.trailing, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    var previewSection: some View {
        let size = UIScreen.width

        return ZStack(alignment: .topLeading) {
            CameraRepresentableView(
                proxy: proxy,
                onStateChanged: { cameraState = $0 },
                onCapture: { store.send(.photoCaptured($0)) },
                onError: { cameraError = $0 }
            )
            .frame(width: size, height: size)
            .clipShape(.rect(cornerRadius: 34))

            overlayBadges
                .padding(16)
        }
        .frame(width: size, height: size)
        .contentShape(.rect)
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    proxy.send(.setZoomFromPinch(magnification: value.magnification))
                }
                .onEnded { _ in
                    proxy.send(.endPinchZoom)
                }
        )
    }

    var overlayBadges: some View {
        HStack(spacing: 6) {
            Text(store.overlayDate)
                .font(.caption1Semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.blackAlpha300)
                .clipShape(.capsule)

            Text(store.overlayLabel)
                .font(.caption1Semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.blackAlpha300)
                .clipShape(.capsule)
        }
    }
}

// MARK: - Zoom Controls

private extension CameraView {
    var selfieZoomToggle: some View {
        let isWide = cameraState.currentZoomFactor <= 1.0
        let icon: Image = isWide ? .icShrink : .icExpand

        return Button {
            proxy.send(.toggleSelfieZoom)
        } label: {
            icon
                .resizable()
                .frame(width: 24, height: 24)
                .padding(6)
                .background(Color.whiteAlpha600)
                .clipShape(.circle)
        }
    }

    var zoomSelector: some View {
        GeometryReader { geometry in
            let sidePadding = geometry.size.width / 2 - 16

            ScrollViewReader { scrollProxy in
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
                    scrollProxy.scrollTo(cameraState.activePreset, anchor: .center)
                }
                .onChange(of: cameraState.activePreset) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollProxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 36)
    }

    func zoomButton(for level: ZoomLevel) -> some View {
        let isActive = cameraState.activePreset == level
        let text = cameraState.zoomButtonTexts[level] ?? level.displayText
        return Button {
            proxy.send(.setZoom(factor: level.rawValue, animated: true))
        } label: {
            Text(text)
                .font(.body2Regular)
                .foregroundStyle(isActive ? Color.gray900 : Color.gray50)
                .frame(width: 36, height: 36)
                .background(isActive ? Color.whiteAlpha600 : Color.clear)
                .clipShape(.circle)
        }
    }
}

// MARK: - Bottom Controls

private extension CameraView {
    var bottomControls: some View {
        HStack(spacing: 48) {
            Spacer()
            flashButton
            captureButton
            switchCameraButton
            Spacer()
        }
        .padding(.vertical, 12)
    }

    var flashButton: some View {
        let icon: Image = cameraState.isFlashOn ? .icFlash : .icFlashOff
        let foregroundColor: Color = isFlashButtonFeedbackVisible ? .green600 : .gray800

        return Button {
            proxy.send(.toggleFlash)
            showControlFeedback(.flash)
        } label: {
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(foregroundColor)
                .frame(width: 20, height: 20)
                .padding(12)
                .background(Color.whiteAlpha600)
                .clipShape(.circle)
        }
    }

    var captureButton: some View {
        var image: Image {
            switch Season.currentSeason {
            case .spring:
                return .imgCameraButtonSpring
            case .summer:
                return .imgCameraButtonSummer
            case .autumn:
                return .imgCameraButtonAutumn
            case .winter:
                return .imgCameraButtonWinter
            }
        }

        return Button {
            proxy.send(.capturePhoto)
        } label: {
            image
                .resizable()
                .frame(width: 70, height: 70)
                .clipShape(.circle)
                .padding(1)
                .background(Color.black)
                .clipShape(.circle)
                .padding(4)
                .background(Color.whiteAlpha300)
                .clipShape(.circle)
        }
    }

    var switchCameraButton: some View {
        let foregroundColor: Color = isSwitchCameraButtonFeedbackVisible ? .green600 : .gray800

        return Button {
            proxy.send(.switchCamera)
            showControlFeedback(.switchCamera)
        } label: {
            Image.icCameraFlip
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(foregroundColor)
                .frame(width: 20, height: 20)
                .padding(12)
                .background(Color.whiteAlpha600)
                .clipShape(.circle)
        }
        .disabled(cameraState.isSwitchingCamera)
    }

    func showControlFeedback(_ target: CameraControlFeedbackTarget) {
        switch target {
        case .flash:
            flashButtonFeedbackTask?.cancel()
            isFlashButtonFeedbackVisible = true
            flashButtonFeedbackTask = Task {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    isFlashButtonFeedbackVisible = false
                    flashButtonFeedbackTask = nil
                }
            }

        case .switchCamera:
            switchCameraButtonFeedbackTask?.cancel()
            isSwitchCameraButtonFeedbackVisible = true
            switchCameraButtonFeedbackTask = Task {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    isSwitchCameraButtonFeedbackVisible = false
                    switchCameraButtonFeedbackTask = nil
                }
            }
        }
    }

    func clearControlFeedback() {
        flashButtonFeedbackTask?.cancel()
        switchCameraButtonFeedbackTask?.cancel()
        flashButtonFeedbackTask = nil
        switchCameraButtonFeedbackTask = nil
        isFlashButtonFeedbackVisible = false
        isSwitchCameraButtonFeedbackVisible = false
    }
}

private enum CameraControlFeedbackTarget {
    case flash
    case switchCamera
}
