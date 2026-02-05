//
//  DefaultHeaders.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

enum DefaultHeaders {

    static var common: [String : String] {
        var headers: [String: String] = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "App-Platform": "ios",
            "X-Analytics-ID": KeyManager.getAPIKey() ?? "",
            "App-Version": Bundle.main
                .infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        ]
        return headers
    }
    
    static var withoutAuth: [String : String] {
        var headers = common
        headers.removeValue(forKey: "Authorization")
        return headers
    }
}
