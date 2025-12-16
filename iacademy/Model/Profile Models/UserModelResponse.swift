//
//  UserModelResponse.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct UserModelResponse: Codable {
    let id: Int?
    let name, avatar, gender: String?
    let email, phone, phoneCode: String?
    let speciality: Speciality?
    let unreadNotificationsCount: Int?
    let accountVerified: Bool?
    let activated: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, avatar, gender, email, phone
        case phoneCode = "phone_code"
        case speciality
        case unreadNotificationsCount = "unread_notifications_count"
        case accountVerified = "account_verified"
        case activated
    }
}
