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
    @State private var focusExposurePoint: CGPoint?
    @State private var focusExposureScale: CGFloat = 1
    @State private var exposureOffset: CGFloat = 0
    @State private var exposureDragBaseOffset: CGFloat = 0
    @State private var isExposureDragging = false
    @State private var isExposureGuideVisible = false
    @State private var focusExposureDismissTask: Task<Void, Never>?
    @State private var focusExposureAnimationTask: Task<Void, Never>?
    @State private var exposureGuideDismissTask: Task<Void, Never>?

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
            clearFocusExposureFeedback()
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

            focusExposureOverlay(previewSize: size)
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
        .simultaneousGesture(focusExposureGesture(previewSize: size))
    }

    var overlayBadges: some View {
        HStack(spacing: 6) {
            Text(store.overlayDate)
                .font(.caption1Semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background {
                    ZStack {
                        CustomBackdropBlurView(radius: 10)
                        Color.blackAlpha300
                    }
                }
                .clipShape(.capsule)

            Text(store.overlayLabel)
                .font(.caption1Semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background {
                    ZStack {
                        CustomBackdropBlurView(radius: 10)
                        Color.blackAlpha300
                    }
                }
                .clipShape(.capsule)
        }
    }

    @ViewBuilder
    func focusExposureOverlay(previewSize: CGFloat) -> some View {
        if let focusExposurePoint {
            FocusExposureIndicator(
                point: focusExposurePoint,
                scale: focusExposureScale,
                exposureOffset: exposureOffset,
                isExposureGuideVisible: isExposureGuideVisible,
                previewSize: previewSize
            ) { translationY in
                updateExposureFeedback(with: translationY)
            } onExposureDragEnded: {
                scheduleExposureGuideDismiss()
            }
            .transition(.opacity)
        }
    }

    func focusExposureGesture(previewSize: CGFloat) -> some Gesture {
        SpatialTapGesture(coordinateSpace: .local)
            .onEnded { value in
                let location = clampedPoint(value.location, in: previewSize)
                showFocusExposureFeedback(at: location)
                scheduleFocusExposureFeedbackDismiss()
            }
    }

    func showFocusExposureFeedback(at location: CGPoint) {
        focusExposureDismissTask?.cancel()
        focusExposureAnimationTask?.cancel()

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            focusExposurePoint = nil
            focusExposureScale = 1.16
            exposureOffset = 0
            exposureDragBaseOffset = 0
            isExposureDragging = false
            isExposureGuideVisible = false
        }

        withTransaction(transaction) {
            focusExposurePoint = location
        }

        focusExposureAnimationTask = Task {
            await Task.yield()
            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.24)) {
                    focusExposureScale = 1
                }
                focusExposureAnimationTask = nil
            }
        }

        proxy.send(.focusAndExpose(at: location))
        proxy.send(.setExposureBiasAdjustment(0))
    }

    func updateExposureFeedback(with translationY: CGFloat) {
        focusExposureDismissTask?.cancel()
        exposureGuideDismissTask?.cancel()
        isExposureGuideVisible = true

        if !isExposureDragging {
            exposureDragBaseOffset = exposureOffset
            isExposureDragging = true
        }

        let visualOffset = exposureDragBaseOffset + translationY * 0.08
        exposureOffset = max(min(visualOffset, 86), -86)

        let adjustment = Float(-exposureOffset / 86 * 4)
        proxy.send(.setExposureBiasAdjustment(adjustment))
    }

    func scheduleExposureGuideDismiss() {
        exposureGuideDismissTask?.cancel()
        isExposureDragging = false
        exposureDragBaseOffset = exposureOffset
        scheduleFocusExposureFeedbackDismiss()
        exposureGuideDismissTask = Task {
            try? await Task.sleep(for: .seconds(0.45))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.12)) {
                    isExposureGuideVisible = false
                }
                exposureGuideDismissTask = nil
            }
        }
    }

    func scheduleFocusExposureFeedbackDismiss() {
        focusExposureDismissTask?.cancel()
        focusExposureDismissTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.18)) {
                    focusExposurePoint = nil
                }
                focusExposureDismissTask = nil
            }
        }
    }

    func clearFocusExposureFeedback() {
        focusExposureDismissTask?.cancel()
        focusExposureAnimationTask?.cancel()
        exposureGuideDismissTask?.cancel()
        focusExposureDismissTask = nil
        focusExposureAnimationTask = nil
        exposureGuideDismissTask = nil
        focusExposurePoint = nil
        focusExposureScale = 1
        exposureOffset = 0
        exposureDragBaseOffset = 0
        isExposureDragging = false
        isExposureGuideVisible = false
        proxy.send(.resetFocusAndExposure)
    }

    func clampedPoint(_ point: CGPoint, in size: CGFloat) -> CGPoint {
        CGPoint(
            x: min(max(point.x, 0), size),
            y: min(max(point.y, 0), size)
        )
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
                .scrollDisabled(true)
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
        let seasonColor = store.solarTerm.season.color(.scale600)
        let foregroundColor: Color = isFlashButtonFeedbackVisible ? seasonColor : .gray800

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
        let seasonColor = store.solarTerm.season.color(.scale600)
        let foregroundColor: Color = isSwitchCameraButtonFeedbackVisible ? seasonColor : .gray800

        return Button {
            clearFocusExposureFeedback()
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

private struct FocusExposureIndicator: View {
    let point: CGPoint
    let scale: CGFloat
    let exposureOffset: CGFloat
    let isExposureGuideVisible: Bool
    let previewSize: CGFloat
    let onExposureDragChanged: (CGFloat) -> Void
    let onExposureDragEnded: () -> Void

    private let accentColor = Color.yellow
    private let reticleSize: CGFloat = 68
    private let lineWidth: CGFloat = 1.1
    private let tickLength: CGFloat = 10
    private let sunSize: CGFloat = 22
    private let sunSpacing: CGFloat = 25
    private let exposureGuideHeight: CGFloat = 172

    var body: some View {
        ZStack(alignment: .topLeading) {
            reticle
                .allowsHitTesting(false)

            exposureControl
        }
        .frame(width: previewSize, height: previewSize)
        .clipped()
    }

    private var reticle: some View {
        Rectangle()
            .stroke(accentColor, lineWidth: lineWidth)
            .frame(width: reticleSize, height: reticleSize)
            .overlay(reticleTicks)
            .scaleEffect(scale)
            .position(point)
    }

    private var reticleTicks: some View {
        ZStack {
            Rectangle()
                .fill(accentColor)
                .frame(width: lineWidth, height: tickLength)
                .frame(maxHeight: .infinity, alignment: .top)

            Rectangle()
                .fill(accentColor)
                .frame(width: lineWidth, height: tickLength)
                .frame(maxHeight: .infinity, alignment: .bottom)

            Rectangle()
                .fill(accentColor)
                .frame(width: tickLength, height: lineWidth)
                .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(accentColor)
                .frame(width: tickLength, height: lineWidth)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var exposureControl: some View {
        let x = exposureControlX
        let centerY = exposureControlCenterY
        let sunY = min(
            max(centerY + exposureOffset, centerY - exposureGuideHeight / 2),
            centerY + exposureGuideHeight / 2
        )

        return ZStack {
            if isExposureGuideVisible {
                Rectangle()
                    .fill(accentColor)
                    .frame(width: lineWidth, height: exposureGuideHeight)
                    .position(x: x, y: centerY)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }

            Image(systemName: "sun.max.fill")
                .font(.system(size: sunSize, weight: .regular))
                .foregroundStyle(accentColor)
                .frame(width: 42, height: 42)
                .contentShape(.rect)
                .position(x: x, y: sunY)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            onExposureDragChanged(value.translation.height)
                        }
                        .onEnded { _ in
                            onExposureDragEnded()
                        }
                )
        }
    }

    private var exposureControlX: CGFloat {
        let rightSpace = previewSize - (point.x + reticleSize / 2)
        let leftSpace = point.x - reticleSize / 2
        let x = rightSpace >= leftSpace
            ? point.x + reticleSize / 2 + sunSpacing
            : point.x - reticleSize / 2 - sunSpacing

        return min(max(x, 21), previewSize - 21)
    }

    private var exposureControlCenterY: CGFloat {
        point.y
    }
}
