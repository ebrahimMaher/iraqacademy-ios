//
//  RegisterResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct RegisterResponseModel: Codable {
    let message: String?
    let user: UserModelResponse?
}
