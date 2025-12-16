//
//  ChangePasswordRequestModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct ChangePasswordRequestModel: Codable {
    var current_password: String
    var password: String
    
    init() {
        self.current_password = ""
        self.password = ""
    }
}
