//
//  CacheClient.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

enum UserDefaultKeys: String, CaseIterable {
    case authToken = "AuthToken"
    case fcmToken = "FCMToken"
    case isAccountVerified = "IsAccountVerified"
    case userModel = "UserModel"
    case appInfo = "AppInfo"
    case lastLoginPhone = "LastLoginPhone"
    case homeToolTipShownBefore = "HomeToolTipShownBefore"
    case settingsEnableNotification = "SettingsEnableNotification"
}

class CacheClient {
    
    static let shared = CacheClient()
    
    var authToken: String {
        get { return get(key: UserDefaultKeys.authToken.rawValue) as? String ?? "" }
        set { set(value: newValue, key: UserDefaultKeys.authToken.rawValue) }
    }
    
    var fcmToken: String {
        get { return get(key: UserDefaultKeys.fcmToken.rawValue) as? String ?? "" }
        set { set(value: newValue, key: UserDefaultKeys.fcmToken.rawValue) }
    }
    
    var isAccountVerified: Bool {
        get { return get(key: UserDefaultKeys.isAccountVerified.rawValue) as? Bool ?? false }
        set { set(value: newValue, key: UserDefaultKeys.isAccountVerified.rawValue) }
    }
    
    var userModel: UserModelResponse? {
        get { return getObject(forKey: UserDefaultKeys.userModel.rawValue, castTo: UserModelResponse.self) }
        set { setObject(newValue, forKey: UserDefaultKeys.userModel.rawValue) }
    }
    
    var appInfo: AppInfoModel? {
        get { return getObject(forKey: UserDefaultKeys.appInfo.rawValue, castTo: AppInfoModel.self) }
        set { setObject(newValue, forKey: UserDefaultKeys.appInfo.rawValue) }
    }
    
    var homeToolTipShownBefore: Bool {
        get { return get(key: UserDefaultKeys.homeToolTipShownBefore.rawValue) as? Bool ?? false }
        set { set(value: newValue, key: UserDefaultKeys.homeToolTipShownBefore.rawValue) }
    }
    
    var settingsEnableNotification: Bool {
        get { return get(key: UserDefaultKeys.settingsEnableNotification.rawValue) as? Bool ?? false }
        set { set(value: newValue, key: UserDefaultKeys.settingsEnableNotification.rawValue) }
    }
    
    func clear(for key: UserDefaultKeys) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key.rawValue)
        defaults.synchronize()
    }
    
    var lastLoginPhone: String {
        get { return get(key: UserDefaultKeys.lastLoginPhone.rawValue) as? String ?? "" }
        set { set(value: newValue, key: UserDefaultKeys.lastLoginPhone.rawValue) }
    }
    
    func clearAll() {
        let defaults = UserDefaults.standard
        for key in UserDefaultKeys.allCases {
            if key == .appInfo || key == .lastLoginPhone || key == .fcmToken || key == .homeToolTipShownBefore || key == .settingsEnableNotification { continue }
            defaults.removeObject(forKey: key.rawValue)
            defaults.synchronize()
        }
    }
    
    private func set(value: Any, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    private func setObject<T>(_ object: T, forKey: String) where T: Encodable {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(object) {
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: forKey)
            defaults.synchronize()

        }
    }

    private func remove(key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }


    private func check(forKey key: String) -> Bool {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: key) != nil {
            return true
        }
        return false
    }

    private func get(key: String) -> Any? {
        if check(forKey: key) {
            let defaults = UserDefaults.standard
            return defaults.value(forKey: key)!
        }
        return nil
    }

    private func getObject<T>(forKey key: String, castTo type: T.Type) -> T? where T: Decodable {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedObj = try? decoder.decode(type.self, from: savedData) {
                return loadedObj
            }
        }
        return nil
    }
}
