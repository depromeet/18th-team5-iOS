//
//  CameraController+Lifecycle.swift
//  Camera
//
//  Created by 진준호 on 5/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import UIKit

// MARK: - App Lifecycle

extension CameraController {
    nonisolated func setupAppLifecycleObservers() {
        observerState.backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let isRunning = self.mutableState.withLock { $0.sessionPhase == .running }
            guard isRunning else { return }
            self.mutableState.withLock { $0.wasRunningBeforeBackground = true }
            self.performSessionStop()
        }

        observerState.foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let wasRunning = self.mutableState.withLock {
                let value = $0.wasRunningBeforeBackground
                $0.wasRunningBeforeBackground = false
                return value
            }
            guard wasRunning else { return }
            self.sessionQueue.async { [weak self] in
                guard let self else { return }
                do {
                    try self.configureSessionGuarded()
                    if !self.session.isRunning {
                        self.session.startRunning()
                    }
                    Task { @MainActor [weak self] in
                        self?.isSessionRunning = true
                    }
                } catch {
                    self.logger.error(message: "포그라운드 복귀 시 세션 복구 실패: \(error)")
                    Task { @MainActor [weak self] in
                        self?.isSessionRunning = false
                        self?.errorMessage = "카메라를 다시 시작할 수 없습니다."
                    }
                }
            }
        }
    }
}
