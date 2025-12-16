//
//  LectureVideoLinkModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation
import CryptoKit

struct LectureVideoLinkModel: Codable {
    let url: String?
    let type: String?  // vdocipher or mp4
    let otp: VDOCipherVideoStrings?
    let playbackInfo: String?
    let videoId: VDOCipherVideoStrings?
    let urls: [URLElement]?
    let vu, cu, lu: VDOCipherVideoStrings?
    
    struct URLElement: Codable {
        let url: String
        let quality: String
    }
    
    struct VDOCipherVideoStrings: Codable {
        let str1: String?
        let str2: String?
        let str3: String?
    }
    
    func decryptVideoIDsVdoCipher() -> String? {
        guard let videoId1 = videoId?.str1, let videoId2 = videoId?.str2, let videoId3 = videoId?.str3 else { return nil }
        
        let deviceSecret = Environment.vdoKey + KeychainClient.shared.getPersistentUUID()
        let keyData = Data(SHA256.hash(data: deviceSecret.data(using: .utf8)!))
        let key = SymmetricKey(data: keyData)
        
        guard let iv = Data(base64Encoded: videoId1),
              let ct = Data(base64Encoded: videoId2),
              let tag = Data(base64Encoded: videoId3) else {
            return nil
        }
        
        guard let sealedBox = try? AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: iv),
            ciphertext: ct,
            tag: tag
        ) else {
            return nil
        }
        
        guard let plain = try? AES.GCM.open(sealedBox, using: key) else { return nil }
        
        guard let result = String(data: plain, encoding: .utf8) else {
            return nil
        }
        return result

    }
    
    func decryptOTPVdoCipher() -> String? {
        guard let otp1 = otp?.str1, let otp2 = otp?.str2, let otp3 = otp?.str3 else { return nil }
        
        let deviceSecret = Environment.vdoKey + KeychainClient.shared.getPersistentUUID()
        let keyData = Data(SHA256.hash(data: deviceSecret.data(using: .utf8)!))
        let key = SymmetricKey(data: keyData)
        
        guard let iv = Data(base64Encoded: otp1),
              let ct = Data(base64Encoded: otp2),
              let tag = Data(base64Encoded: otp3) else {
            return nil
        }
        
        guard let sealedBox = try? AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: iv),
            ciphertext: ct,
            tag: tag
        ) else {
            return nil
        }
        
        guard let plain = try? AES.GCM.open(sealedBox, using: key) else { return nil }
        
        guard let result = String(data: plain, encoding: .utf8) else {
            return nil
        }
        return result
    }
    
    
    func decryptURLDrm() -> String? {
        guard let videoURL1 = vu?.str1, let videoURL2 = vu?.str2, let videoURL3 = vu?.str3 else { return nil }
        
        let deviceSecret = Environment.vdoKey + KeychainClient.shared.getPersistentUUID()
        let keyData = Data(SHA256.hash(data: deviceSecret.data(using: .utf8)!))
        let key = SymmetricKey(data: keyData)
        
        guard let iv = Data(base64Encoded: videoURL1),
              let ct = Data(base64Encoded: videoURL2),
              let tag = Data(base64Encoded: videoURL3) else {
            return nil
        }
        
        guard let sealedBox = try? AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: iv),
            ciphertext: ct,
            tag: tag
        ) else {
            return nil
        }
        
        guard let plain = try? AES.GCM.open(sealedBox, using: key) else { return nil }
        
        guard let result = String(data: plain, encoding: .utf8) else {
            return nil
        }
        return result

    }
    
    func decryptLicenseDrm() -> String? {
        guard let lic1 = lu?.str1, let lic2 = lu?.str2, let lic3 = lu?.str3 else { return nil }
        
        let deviceSecret = Environment.vdoKey + KeychainClient.shared.getPersistentUUID()
        let keyData = Data(SHA256.hash(data: deviceSecret.data(using: .utf8)!))
        let key = SymmetricKey(data: keyData)
        
        guard let iv = Data(base64Encoded: lic1),
              let ct = Data(base64Encoded: lic2),
              let tag = Data(base64Encoded: lic3) else {
            return nil
        }
        
        guard let sealedBox = try? AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: iv),
            ciphertext: ct,
            tag: tag
        ) else {
            return nil
        }
        
        guard let plain = try? AES.GCM.open(sealedBox, using: key) else { return nil }
        
        guard let result = String(data: plain, encoding: .utf8) else {
            return nil
        }
        return result

    }
    
    func decryptCertificateDrm() -> String? {
        guard let cer1 = cu?.str1, let cer2 = cu?.str2, let cer3 = cu?.str3 else { return nil }
        
        let deviceSecret = Environment.vdoKey + KeychainClient.shared.getPersistentUUID()
        let keyData = Data(SHA256.hash(data: deviceSecret.data(using: .utf8)!))
        let key = SymmetricKey(data: keyData)
        
        guard let iv = Data(base64Encoded: cer1),
              let ct = Data(base64Encoded: cer2),
              let tag = Data(base64Encoded: cer3) else {
            return nil
        }
        
        guard let sealedBox = try? AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: iv),
            ciphertext: ct,
            tag: tag
        ) else {
            return nil
        }
        
        guard let plain = try? AES.GCM.open(sealedBox, using: key) else { return nil }
        
        guard let result = String(data: plain, encoding: .utf8) else {
            return nil
        }
        return result

    }
    
}
