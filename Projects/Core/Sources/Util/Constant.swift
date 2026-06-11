//
//  Constant.swift
//  Core
//
//  Created by 이정원 on 6/11/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum Constant {
    public static let testFlightURL: String = Bundle.value(of: "TestFlightURL") ?? ""
    public static let appStoreURL: String = Bundle.value(of: "AppStoreURL") ?? ""
    public static let commonDebugToken = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
}
