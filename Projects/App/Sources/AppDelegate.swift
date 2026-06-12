//
//  AppDelegate.swift
//  App
//
//  Created by choijunios on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Core
import Data
import Dependencies
import Domain
import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        configureNotification()
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        syncNotificationSettings()
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // TODO: Failed to register for remote notifications
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        handleNotification(response)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // TODO: Send the refreshed FCM token to the server when the API is ready.
        // print(fcmToken)
    }
}

private extension AppDelegate {
    func configureNotification() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func syncNotificationSettings() {
        Task {
            do {
                @Dependency(\.notificationRepository) var notificationRepository
                let settings = try await notificationRepository.fetchNotificationSettings()
                guard let settings else { return }
                try await notificationRepository.syncNotificationSettings(settings)
            } catch {
                // TODO: 에러 처리 - @ 정원
            }
        }
    }

    func handleNotification(_ response: UNNotificationResponse) {
        @Dependency(\.notificationRepository) var notificationRepository
        let userInfo = response.notification.request.content.userInfo as? [String: Any]
        let typeString = userInfo?["type"] as? String
        let type = NotificationType(typeString)

        guard let type else { return }
        notificationRepository.setPendingNotificationType(type)
        NotificationCenter.default.post(name: .pushNotificationTapped, object: nil)
    }
}
