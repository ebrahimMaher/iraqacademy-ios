//
//  Data.swift
//  iacademy
//
//  Created by Marwan Osama on 24/01/2026.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
