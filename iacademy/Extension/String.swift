//
//  String.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit

extension String {
    
    var containsNumber: Bool {
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    var normalizedArabic: String {
        var text = self
        let arabicLettersMap: [Character: Character] = [
            "أ": "ا",
            "إ": "ا",
            "آ": "ا",
            "ى": "ي",
            "ئ": "ي",
            "ؤ": "و"
        ]
        
        for (original, replacement) in arabicLettersMap {
            text = text.replacingOccurrences(of: String(original), with: String(replacement))
        }
        
        return text
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "(?:[A-Z0-9a-z._%+-]+)@(?:[A-Za-z0-9-]+\\.)+[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPasswordLength: Bool {
        return count >= 6 && count <= 255
    }
    
    func slice(between: String, and: String?) -> String? {
        guard let startRange = range(of: between) else { return nil }
        let startIndex = startRange.upperBound
        let endIndex: String.Index
        if let and = and, let endRange = range(of: and, range: startIndex..<endIndexOf(of: self)) {
            endIndex = endRange.lowerBound
        } else {
            endIndex = self.endIndex
        }
        return String(self[startIndex..<endIndex])
    }
    
    func endIndexOf(of text: String) -> String.Index {
        return text.endIndex
    }
    
    
}
