//
//  EditProfileRequestModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct EditProfileRequestModel: Codable {
    var name: String
    var email: String
    
    init() {
        self.name = ""
        self.email = ""
    }
}
