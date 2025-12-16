//
//  UUIDEncryptor.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

class UUIDEncryptor {
    
    static func encryptUUIDPayloadWithPemKey() -> String? {
        guard let path = Bundle.main.path(forResource: "public_key", ofType: "pem"),
              let pemString = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("❌ Failed to load PEM file")
            return nil
        }
        
        guard let secKey = createSecKey(from: pemString) else {
            print("❌ Could not create SecKey")
            return nil
        }
        
        if let encryptedPayload = generateEncryptedPayload(publicKey: secKey) {
            print("🔒 Final Encrypted Payload:\n\(encryptedPayload)")
            return encryptedPayload
        } else {
            print("❌ Encryption failed")
            return nil
        }
    }
    
    
    private static func createSecKey(from pemString: String) -> SecKey? {
        let keyString = pemString
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let keyData = Data(base64Encoded: keyString) else {
            print("❌ Failed to decode base64 public key")
            return nil
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048,
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData,
                                                attributes as CFDictionary,
                                                &error) else {
            print("❌ Failed to create SecKey: \(error!.takeRetainedValue())")
            return nil
        }
        return secKey
    }
    
    
    
    private static func generateEncryptedPayload(publicKey: SecKey) -> String? {
        var uuid = KeychainClient.shared.getPersistentUUID()
        let insertIndex = uuid.index(uuid.startIndex, offsetBy: 3)
        uuid.insert("N", at: insertIndex)
        let timestamp = Int(Date().timeIntervalSince1970)
        let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12)
        
        let payload: [String: Any] = [
            "uuid": uuid,
            "timestamp": timestamp,
            "nonce": String(nonce)
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionPKCS1,
            jsonString.data(using: .utf8)! as CFData,
            &error
        ) as Data? else {
            print("Encryption error: \(error!.takeRetainedValue())")
            return nil
        }
        return encryptedData.base64EncodedString()
    }

}
