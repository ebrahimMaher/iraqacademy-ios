//
//  NetworkErrorModel.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

struct NetworkErrorModel: Codable {
    let message: String?
    let errors: [String: [String]]?
    let wait_minutes: Int?
    
}
