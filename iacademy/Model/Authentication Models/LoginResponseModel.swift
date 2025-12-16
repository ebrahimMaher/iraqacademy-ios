//
//  LoginResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct LoginResponseModel: Codable {
    let token: String?
    let user: UserModelResponse?
}
