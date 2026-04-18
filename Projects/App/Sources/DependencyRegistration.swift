//
//  DependencyRegistration.swift
//  App
//
//  Created by 진준호 on 4/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Data
import Dependencies
import Domain

// MARK: - Repository는 Data 모듈의 구현체를 연결해야 하므로 App에서 DependencyKey 등록

extension ExampleRepository: @retroactive DependencyKey {
    public static let liveValue: ExampleRepository = ExampleRepositoryImpl.live()
}
