//
//  KeychainClient.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation
import Security

class KeychainClient {
    
    static let shared = KeychainClient()
    
    func getPersistentUUID() -> String {
        let account = "com.iacademy.plus.deviceUUID"
        let service = "com.iacademy.plus.service"

        if let uuidData = loadKeychain(account: account, service: service) {
            return String(data: uuidData, encoding: .utf8) ?? UUID().uuidString
        } else {
            let newUUID = UUID().uuidString
            saveKeychain(data: Data(newUUID.utf8), account: account, service: service)
            return newUUID
        }
    }

    func loadKeychain(account: String, service: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }

    func saveKeychain(data: Data, account: String, service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
}
