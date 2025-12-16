//
//  KeyManager.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation
import CryptoKit
import Security

struct KeyManager {
    
    private static let keychainKey = "com.iacademy.plus.apiKey"
    
    
    static func getAPIKey() -> String? {
        
        if let stored = loadFromKeychain() {
            return stored
        }
        
        guard let decrypted = decryptFromPlist() else { return nil }
        saveToKeychain(apiKey: decrypted)
        return decrypted
    }
    
    private static func decryptFromPlist() -> String? {
        let encryptedBase64 = Environment.apiKey
        let passphrase = Environment.passPhrase
        guard let encryptedData = Data(base64Encoded: encryptedBase64)
        else {
            print("wrong encrypted data")
            return nil
        }
        
        let hash = SHA256.hash(data: passphrase.data(using: .utf8)!)
        let symmetricKey = SymmetricKey(data: hash)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Failed to decrypt API key: \(error)")
            return nil
        }
    }
    
    private static func saveToKeychain(apiKey: String) {
        let data = apiKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary) // cleanup old
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private static func loadFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    
}
