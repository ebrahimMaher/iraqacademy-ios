//
//  Collection.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
