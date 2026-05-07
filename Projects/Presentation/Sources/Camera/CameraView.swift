//
//  CameraView.swift
//  Presentation
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct CameraView: View {
    private let store: StoreOf<CameraFeature>

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

                if store.isFrontCamera {
                    selfieZoomToggle
                } else {
                    zoomSelector
                }

                Spacer()

                bottomControls
                    .padding(.bottom, 98)
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}

private extension CameraView {
    var closeButton: some View {
        Button {
            store.send(.closeButtonTapped)
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
                if let session = store.captureSession?.session {
                    CameraPreviewView(session: session)
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 34))
                }

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
                        store.send(.pinchZoomChanged(value.magnification))
                    }
                    .onEnded { _ in
                        store.send(.pinchZoomEnded)
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

    // MARK: - 전면 카메라 줌 토글 (프리셋 버튼 위치)

    var selfieZoomToggle: some View {
        let isWide = store.currentZoomFactor <= 1.0
        return Button {
            store.send(.selfieZoomToggleTapped)
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

    // MARK: - 줌 프리셋 버튼 (후면 카메라 전용)

    var zoomSelector: some View {
        GeometryReader { geometry in
            let sidePadding = geometry.size.width / 2 - 16

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(CameraFeature.ZoomLevel.allCases, id: \.self) { level in
                            zoomButton(for: level)
                                .id(level)
                        }
                    }
                    .padding(.horizontal, sidePadding)
                }
                .onAppear {
                    proxy.scrollTo(store.activePreset, anchor: .center)
                }
                .onChange(of: store.activePreset) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 32)
        .padding(.top, 24)
    }

    func zoomButton(for level: CameraFeature.ZoomLevel) -> some View {
        let isActive = store.activePreset == level
        let text = store.zoomButtonTexts[level] ?? level.displayText
        return Button { store.send(.zoomSelected(level)) } label: {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isActive ? .black : .gray500)
                .frame(width: 32, height: 32)
                .background(isActive ? Color.gray200 : Color.clear)
                .clipShape(Circle())
        }
    }

    // MARK: - 하단 컨트롤

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
        Button { store.send(.flashToggleTapped) } label: {
            Image(systemName: store.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(Color.gray300)
                .clipShape(Circle())
        }
    }

    var captureButton: some View {
        Button {
            store.send(.captureButtonTapped)
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
        Button { store.send(.switchCameraTapped) } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(Color.gray300)
                .clipShape(Circle())
        }
    }
}
