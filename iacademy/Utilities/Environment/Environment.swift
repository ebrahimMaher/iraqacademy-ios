//
//  Environment.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

public enum Environment {
    
    enum Keys {
        enum Plist {
            static let BASE_API_URL = "BASE_API_URL"
            static let API_KEY = "API_KEY"
            static let PASS_PHRASE = "PASS_PHRASE"
            static let VDO_KEY = "VDO_KEY"
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    static let apiUrl: String = {
        guard let apiKey = Environment.infoDictionary[Keys.Plist.BASE_API_URL] as? String else {
            fatalError("BASE_API_URL not set in plist for this environment")
        }
        return apiKey
    }()
    
    static let apiKey: String = {
        guard let apiKey = Environment.infoDictionary[Keys.Plist.API_KEY] as? String else {
            fatalError("API_KEY not set in plist for this environment")
        }
        return apiKey
    }()
    
    static let passPhrase: String = {
        guard let passPhrase = Environment.infoDictionary[Keys.Plist.PASS_PHRASE] as? String else {
            fatalError("PASS_PHRASE not set in plist for this environment")
        }
        return passPhrase
    }()
    
    static let vdoKey: String = {
        guard let vdoKey = Environment.infoDictionary[Keys.Plist.VDO_KEY] as? String else {
            fatalError("VDO_KEY not set in plist for this environment")
        }
        return vdoKey
    }()
    
    
    
    static let isDebugBuild: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
}
