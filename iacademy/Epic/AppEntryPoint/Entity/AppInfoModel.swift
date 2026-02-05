//
//  AppInfoModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct AppInfoModel: Codable {
    let androidStableVersion, iosStableVersion: String?
    let aboutPlatform, playStoreURL, appleStoreURL, telegramURL: String?
    let generalAnnouncement: String?
    let specialities: [Speciality]?
    let accountVerification, appIsDown: Bool?

    enum CodingKeys: String, CodingKey {
        case androidStableVersion = "android_stable_version"
        case iosStableVersion = "ios_stable_version"
        case accountVerification = "account_verification"
        case appIsDown
        case aboutPlatform = "about_platform"
        case playStoreURL = "play_store_url"
        case appleStoreURL = "apple_store_url"
        case telegramURL = "telegram_url"
        case generalAnnouncement = "general_announcement"
        case specialities
    }
}

struct Speciality: Codable {
    let id: Int?
    let name: String?
}
