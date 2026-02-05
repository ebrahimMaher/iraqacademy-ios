//
//  ReportViolationRequestModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct ReportViolationRequestModel: Codable {
    var type: String
    var uuid: String
    
    init() {
        self.type = ""
        self.uuid = KeychainClient.shared.getPersistentUUID()
    }
}
