//
//  StringOrInt.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

@propertyWrapper
struct StringOrInt: Codable {
    var wrappedValue: String?

    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            wrappedValue = String(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            wrappedValue = stringValue
        } else {
            wrappedValue = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
