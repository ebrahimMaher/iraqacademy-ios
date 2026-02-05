//
//  SessionConfiguration.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

enum SessionConfiguration {
    
    static func `default`() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 5
        return config
    }
}
