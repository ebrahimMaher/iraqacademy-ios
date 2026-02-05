//
//  SSLConfiguration.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

// MARK: - SSL Pinning Configuration Manager

class SSLConfiguration {
    static let shared = SSLConfiguration()
    
    private let testingPin = "api-nippur.ebmsoft.net"
    private let productionPin = "api.nippuracademy.com"
    
    private init() {}
    
    // Get current domain based on Environment
    var currentPin: String {
        let currentURL = Environment.apiUrl
        if currentURL.contains(testingPin) {
            return testingPin
        }
        return productionPin
    }
}
