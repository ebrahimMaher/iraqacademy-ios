//
//  AppTextField.swift
//  iacademy
//
//  Created by Marwan Osama on 21/01/2026.
//

import UIKit

class AppTextField: UITextField {

    @IBInspectable var fontWeight: Int = UIFont.AppFontWeight.regular.rawValue {
        didSet { applyFont() }
    }

    @IBInspectable var placeholderColor: UIColor = .Black_400 {
        didSet { applyPlaceholderFont() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyFont()
    }

    private func applyFont() {
        guard let weight = UIFont.AppFontWeight(rawValue: fontWeight) else { return }

        let size = font?.pointSize ?? 16
        let appFont = UIFont.avenir(weight: weight.uiWeight, size: size)

        font = appFont
        applyPlaceholderFont(font: appFont)
    }

    private func applyPlaceholderFont(font: UIFont? = nil) {
        guard let placeholder = placeholder, !placeholder.isEmpty else { return }

        let finalFont = font ?? self.font ?? .systemFont(ofSize: 16)

        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: finalFont,
                .foregroundColor: placeholderColor
            ]
        )
    }
}
