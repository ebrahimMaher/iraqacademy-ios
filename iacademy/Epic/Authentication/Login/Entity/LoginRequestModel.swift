//
//  LoginRequestModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct LoginRequestModel: Codable {
    var phone: String
    var password: String
    var fcm_token: String
    var uuid: String
    
    init() {
        self.phone = ""
        self.password = ""
        self.uuid = UUIDEncryptor.encryptUUIDPayloadWithPemKey() ?? ""
        self.fcm_token = CacheClient.shared.fcmToken
    }
    
    mutating func refreshUUID() {
        self.uuid = UUIDEncryptor.encryptUUIDPayloadWithPemKey() ?? ""
    }
    
    
}
