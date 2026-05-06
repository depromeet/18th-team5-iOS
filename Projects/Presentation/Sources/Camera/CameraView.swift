//
//  CameraView.swift
//  Presentation
//
//  Created by 진준호 on 5/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import AVFoundation
import ComposableArchitecture
import Dependencies
import DesignSystem
import Domain
import SwiftUI

public struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    private let store: StoreOf<CameraFeature>
    private let session: AVCaptureSession

    public init(store: StoreOf<CameraFeature>) {
        self.store = store
        @Dependency(\.cameraClient) var cameraClient
        self.session = cameraClient.getSession()
    }

    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                closeButton
                previewSection

                if !store.isFrontCamera {
                    zoomSelector
                }

                Spacer()

                bottomControls
                    .padding(.bottom, 98)
            }
        }
        .onAppear { store.send(.onAppear) }
        .onDisappear { store.send(.onDisappear) }
    }
}

private extension CameraView {
    var closeButton: some View {
        Button {
            store.send(.closeButtonTapped)
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 24))
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
                CameraPreviewView(session: session)
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

                    zoomLevelOverlay
                        .padding(.bottom, 16)
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

    // MARK: - 줌 레벨 오버레이 (프리뷰 하단)

    @ViewBuilder
    var zoomLevelOverlay: some View {
        if store.isFrontCamera {
            HStack(spacing: 16) {
                Button { store.send(.selfieZoomOutTapped) } label: {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }

                Text(store.zoomLevelText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .monospacedDigit()

                Button { store.send(.selfieZoomInTapped) } label: {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.black.opacity(0.5))
            .clipShape(Capsule())
        } else {
            Text(store.zoomLevelText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.yellow)
                .monospacedDigit()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.5))
                .clipShape(Capsule())
        }
    }

    // MARK: - 줌 프리셋 버튼 (후면 카메라 전용)

    var zoomSelector: some View {
        HStack(spacing: 16) {
            ForEach(CameraFeature.ZoomLevel.allCases, id: \.self) { level in
                Button { store.send(.zoomSelected(level)) } label: {
                    Text(level.displayText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(store.activePreset == level ? .black : .gray500)
                        .frame(width: 32, height: 32)
                        .background(
                            store.activePreset == level
                                ? Color.gray200
                                : Color.clear
                        )
                        .clipShape(Circle())
                }
            }
        }
        .padding(.top, 24)
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
