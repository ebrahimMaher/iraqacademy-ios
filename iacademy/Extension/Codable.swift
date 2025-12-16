//
//  Codable.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

extension Encodable {

    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        let dict = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
        return dict ?? [:]
    }
    
}
