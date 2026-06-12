//
//  MyPageFeature+Path.swift
//  Presentation
//
//  Created by 이정원 on 6/4/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

extension MyPageFeature {
    @Reducer
    public enum Path {
        case notificationSettings(NotificationSettingsFeature)
        case announcements(AnnouncementListFeature)
        case privacyPolicy(PrivacyPolicyFeature)
        case termsOfService(TermsOfServiceFeature)
    }
}

extension MyPageFeature.Path.State: Equatable {}
