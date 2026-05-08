//
//  KeychainHelper.swift
//  Core
//
//  Created by 진준호 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation
import Security

public enum KeychainKey: String, Sendable {
    case deviceID = "com.peaktime.device-id"
    case accessToken = "com.peaktime.access-token"
    case refreshToken = "com.peaktime.refresh-token"
}

public enum KeychainHelper {
    @discardableResult
    public static func save(data: Data, forKey key: KeychainKey) -> Bool {
        let searchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]

        let updateAttributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemUpdate(searchQuery as CFDictionary, updateAttributes as CFDictionary)

        if status == errSecItemNotFound {
            let addQuery = searchQuery.merging(updateAttributes) { _, new in new }
            return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
        }

        return status == errSecSuccess
    }

    @discardableResult
    public static func delete(forKey key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]

        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    public static func load(forKey key: KeychainKey) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
}
