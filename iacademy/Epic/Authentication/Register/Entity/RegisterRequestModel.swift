//
//  RegisterRequestModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct RegisterRequestModel: Codable {
    var name: String
    var birthdate: String
    var country: String
    var phone: String
    var phone_code: String
    var speciality_id: Int
    var email: String
    var password: String
    var uuid: String
    var fcm_token: String
    
    init() {
        self.name = ""
        self.birthdate = ""
        self.country = ""
        self.phone = ""
        self.phone_code = ""
        self.speciality_id = 100
        self.email = ""
        self.password = ""
        self.uuid = UUIDEncryptor.encryptUUIDPayloadWithPemKey() ?? ""
        self.fcm_token = CacheClient.shared.fcmToken
    }
    
    mutating func refreshUUID() {
        self.uuid = UUIDEncryptor.encryptUUIDPayloadWithPemKey() ?? ""
    }
}
